-- ============================================================
-- TASKFLOW — COMPLETE SCHEMA (fresh project)
-- Run this once, top to bottom, in the new project's SQL Editor
-- ============================================================

-- ---------- BASE TABLES ----------

create table if not exists members (
  id uuid primary key default gen_random_uuid(),
  team text not null,
  name text not null,
  role text not null check (role in ('manager','employee','it_support')),
  password text,
  email text,
  push_subscription jsonb,
  last_email_at timestamptz,
  email_sent_count integer default 0
);
create unique index if not exists idx_members_unique on members(team, name);

create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  team text not null,
  title text not null,
  assignee text not null,
  due date,
  status text not null default 'pending' check (status in ('pending','done')),
  description text,
  report_text text,
  report_attachment_url text,
  report_attachment_name text,
  completed_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists tickets (
  id uuid primary key default gen_random_uuid(),
  team text not null,
  raised_by text not null,
  subject text not null,
  message text,
  status text not null default 'open',
  created_at timestamptz default now()
);

create table if not exists login_log (
  id uuid primary key default gen_random_uuid(),
  team text not null,
  name text not null,
  role text,
  logged_in_at timestamptz default now()
);

-- ---------- LOCATION TRACKING ----------
create table if not exists location_logs (
  id uuid primary key default gen_random_uuid(),
  team text not null, employee_name text not null,
  latitude double precision not null, longitude double precision not null,
  recorded_at timestamptz default now()
);

-- ---------- ATTENDANCE ----------
create table if not exists attendance (
  id uuid primary key default gen_random_uuid(),
  team text not null, employee_name text not null,
  check_in_at timestamptz, check_in_lat double precision, check_in_lng double precision,
  check_out_at timestamptz, check_out_lat double precision, check_out_lng double precision,
  work_date date not null default current_date
);
create unique index if not exists idx_attendance_one_per_day on attendance(team, employee_name, work_date);

-- ---------- EXPENSE CLAIMS ----------
create table if not exists expense_claims (
  id uuid primary key default gen_random_uuid(),
  team text not null, employee_name text not null,
  amount numeric(10,2) not null,
  category text not null check (category in ('travel','food','accommodation','other')),
  note text, receipt_url text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  submitted_at timestamptz default now(), reviewed_at timestamptz, reviewed_by text,
  rejection_reason text
);

-- ---------- ON-DUTY REQUESTS ----------
create table if not exists onduty_requests (
  id uuid primary key default gen_random_uuid(),
  team text not null, employee_name text not null,
  request_date date not null, reason text not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  submitted_at timestamptz default now(), reviewed_at timestamptz, reviewed_by text
);
create unique index if not exists idx_onduty_one_per_day on onduty_requests(team, employee_name, request_date);

-- ---------- DEVICE-AUTH OTP ----------
create table if not exists user_devices (
  id uuid primary key default gen_random_uuid(),
  team text not null,
  employee_name text not null,
  device_id text not null,
  device_name text,
  platform text,
  app_version text,
  is_approved boolean not null default false,
  first_seen_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  approved_at timestamptz,
  revoked_at timestamptz
);
create unique index if not exists idx_user_devices_unique on user_devices(team, employee_name, device_id);
create index if not exists idx_user_devices_lookup on user_devices(team, employee_name);

create table if not exists device_otps (
  id uuid primary key default gen_random_uuid(),
  team text not null,
  employee_name text not null,
  device_id text not null,
  code_hash text not null,
  attempts integer not null default 0,
  max_attempts integer not null default 5,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  consumed boolean not null default false,
  consumed_at timestamptz
);
create index if not exists idx_device_otps_lookup on device_otps(team, employee_name, device_id, consumed);

create table if not exists device_otp_requests (
  id uuid primary key default gen_random_uuid(),
  team text not null,
  employee_name text not null,
  device_id text not null,
  requested_at timestamptz not null default now()
);
create index if not exists idx_device_otp_requests_lookup on device_otp_requests(team, employee_name, device_id, requested_at);

-- ---------- SPEED SANITY-CHECK ----------
alter table location_logs add column if not exists is_suspicious boolean not null default false;
alter table location_logs add column if not exists speed_kmh numeric;
create index if not exists idx_location_logs_suspicious on location_logs(team, employee_name, is_suspicious) where is_suspicious = true;

-- ---------- STORAGE BUCKETS ----------
insert into storage.buckets (id, name, public) values ('receipts', 'receipts', true) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('task-attachments', 'task-attachments', true) on conflict (id) do nothing;

-- ---------- PERMISSIONS (RLS) ----------
do $$
declare t text;
begin
  foreach t in array array['members','tasks','tickets','login_log','location_logs','attendance',
                            'expense_claims','onduty_requests','user_devices','device_otps','device_otp_requests']
  loop
    execute format('alter table %I enable row level security;', t);
    execute format('drop policy if exists "%s_all" on %I;', t, t);
    execute format('create policy "%s_all" on %I for all using (true) with check (true);', t, t);
    execute format('grant select, insert, update, delete on %I to anon, authenticated, service_role;', t);
  end loop;
end $$;

drop policy if exists "receipts_all" on storage.objects;
create policy "receipts_all" on storage.objects for all using (bucket_id = 'receipts') with check (bucket_id = 'receipts');
drop policy if exists "task_attachments_all" on storage.objects;
create policy "task_attachments_all" on storage.objects for all using (bucket_id = 'task-attachments') with check (bucket_id = 'task-attachments');
grant select, insert, update, delete on storage.objects to anon, authenticated, service_role;
grant select, insert, update, delete on storage.buckets to anon, authenticated, service_role;
