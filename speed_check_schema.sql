-- Speed sanity-check columns for location_logs
alter table location_logs add column if not exists is_suspicious boolean not null default false;
alter table location_logs add column if not exists speed_kmh numeric;

create index if not exists idx_location_logs_suspicious on location_logs(team, employee_name, is_suspicious) where is_suspicious = true;
