-- 在 Supabase > SQL Editor 中完整运行本文件。
-- 运行完成后，请把最后一行中的管理员邮箱改成你自己的邮箱。

create extension if not exists pgcrypto;

create table if not exists public.survey_responses (
  id uuid primary key default gen_random_uuid(),
  respondent_code text not null,
  job_title text not null,
  tenure text not null,
  ai_awareness text not null,
  work_usage text not null,
  tools text[] not null default '{}',
  tool_other text,
  frequency text not null,
  scenarios text[] not null default '{}',
  scenario_other text,
  impact jsonb not null default '{}'::jsonb,
  report_time_early text,
  report_time_current text,
  saved_time text not null,
  barriers text[] not null default '{}',
  barrier_other text,
  company_ai_training text not null default '未填写',
  ace_ai_certificate text not null default '未填写',
  submitted_at timestamptz not null default now(),
  constraint respondent_code_unique unique (respondent_code),
  constraint respondent_code_length check (char_length(trim(respondent_code)) between 2 and 50)
);

-- 兼容已创建过旧版数据表的项目：重复运行也不会报错。
alter table public.survey_responses
  add column if not exists company_ai_training text not null default '未填写';

alter table public.survey_responses
  add column if not exists ace_ai_certificate text not null default '未填写';

create table if not exists public.survey_admins (
  email text primary key,
  created_at timestamptz not null default now()
);

alter table public.survey_responses enable row level security;
alter table public.survey_admins enable row level security;

drop policy if exists "anyone_can_submit_once" on public.survey_responses;
create policy "anyone_can_submit_once"
on public.survey_responses
for insert
to anon, authenticated
with check (
  char_length(trim(respondent_code)) between 2 and 50
  and job_title <> ''
  and tenure <> ''
  and ai_awareness <> ''
  and work_usage <> ''
  and frequency <> ''
  and saved_time <> ''
  and company_ai_training <> ''
  and ace_ai_certificate <> ''
);

drop policy if exists "admins_can_read_responses" on public.survey_responses;
create policy "admins_can_read_responses"
on public.survey_responses
for select
to authenticated
using (
  exists (
    select 1 from public.survey_admins a
    where lower(a.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  )
);

drop policy if exists "admins_can_verify_self" on public.survey_admins;
create policy "admins_can_verify_self"
on public.survey_admins
for select
to authenticated
using (lower(email) = lower(coalesce(auth.jwt() ->> 'email', '')));

create index if not exists survey_responses_submitted_at_idx
  on public.survey_responses (submitted_at desc);

-- 必须修改：把下面邮箱替换成统计看板管理员邮箱。
insert into public.survey_admins (email)
values ('peghe3@publicisgroupe.net')
on conflict (email) do nothing;
