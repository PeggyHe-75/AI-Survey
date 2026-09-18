-- 已经运行过旧版 supabase-setup.sql 的用户，只需在 SQL Editor 运行本文件。
-- 不会删除或覆盖已有问卷数据。

alter table public.survey_responses
  add column if not exists company_ai_training text not null default '未填写';

alter table public.survey_responses
  add column if not exists ace_ai_certificate text not null default '未填写';

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
