# AI工具使用与工作提效调研

这是一套可多人填写并统一统计的独立 HTML 问卷，包含：

- 问卷填写端
- 云端统一数据收集
- 同一姓名/员工编号防重复提交
- 管理员邮箱登录
- 实时统计看板与筛选
- CSV 明细导出
- 普及率、使用渗透率、稳定使用率和节约工时统计
- 公司／集团AI培训参与率与ACE AI认证统计

> 重要：直接双击 HTML 可以预览页面，但要让所有人提交到同一个数据库，必须完成下方云端配置并部署到网页地址。

## 一、创建 Supabase 数据库

1. 打开 <https://supabase.com> 并注册或登录。
2. 点击 **New project**，创建一个免费项目。
3. 进入项目后，打开左侧 **SQL Editor**。
4. 打开本文件夹中的 `supabase-setup.sql`，把最后的管理员邮箱：

   ```sql
   values ('your.name@company.com')
   ```

   改成你的真实邮箱，例如：

   ```sql
   values ('peggy.he@company.com')
   ```

5. 将完整 SQL 复制到 SQL Editor，点击 **Run**。

如需增加多个管理员，可在 SQL Editor 继续运行：

```sql
insert into public.survey_admins (email)
values ('another.admin@company.com')
on conflict (email) do nothing;
```

## 二、填写网页配置

1. 在 Supabase 打开 **Project Settings → API**。
2. 复制 **Project URL**。
3. 复制 **anon / public key**。这是前端公开密钥，不要使用 `service_role` 密钥。
4. 打开 `config.js`，替换以下两项：

```js
SUPABASE_URL: "你的 Project URL",
SUPABASE_ANON_KEY: "你的 anon public key"
```

还可以修改问卷名称和组织名称。

### 已运行过旧版数据库脚本时

如果你此前已经运行过旧版 `supabase-setup.sql`，请在 Supabase 的 **SQL Editor** 中完整运行 `supabase-update-v2.sql`。该脚本只会新增“集团AI培训”和“ACE AI证书”两个字段，不会删除或覆盖已有问卷数据。

## 三、设置管理员邮件登录

1. 在 Supabase 打开 **Authentication → URL Configuration**。
2. 将最终的问卷网址填入 **Site URL**。
3. 在 **Redirect URLs** 中也添加最终问卷网址，可加通配路径，例如：

   ```text
   https://你的用户名.github.io/你的仓库/**
   ```

管理员进入“统计看板”，输入已加入 `survey_admins` 的邮箱，就会收到一次性登录链接。

## 四、发布到 GitHub Pages

1. 在 GitHub 创建一个新仓库，例如 `ai-usage-survey`。
2. 上传本文件夹里的 `index.html` 和 `config.js`。
3. 仓库中进入 **Settings → Pages**。
4. `Source` 选择 **Deploy from a branch**。
5. Branch 选择 `main`，目录选择 `/ (root)`，点击 **Save**。
6. 等待约 1–3 分钟后，GitHub 会生成公开问卷地址。
7. 将该地址发给同事填写。

`supabase-setup.sql` 和 `README.md` 不影响网页运行，可以一起上传，也可以仅保留在本地。

## 五、统计口径

| 指标 | 看板口径 |
|---|---|
| 有效样本 | 唯一姓名/员工编号提交数 |
| AI认知普及率 | AI认知不为“完全不了解”的人数 ÷ 有效样本 |
| 工作使用渗透率 | 工作中至少尝试过AI的人数 ÷ 有效样本 |
| 稳定使用率 | 每天使用或每周使用2–3天的人数 ÷ 有效样本 |
| 平均日节约工时 | 将选择区间转换为中位值后计算平均值 |

## 六、数据与权限说明

- 普通填写者只能新增一条问卷，不能读取其他人的数据。
- 相同姓名或员工编号不能重复提交。
- 只有 `survey_admins` 表中的邮箱可以读取统计数据。
- 明细表在网页中默认对识别码脱敏；管理员导出的 CSV 包含完整识别码，便于核对是否全员完成。
- Supabase 的 `anon key` 可以放在网页中；切勿把 `service_role key` 放进 `config.js`。

## 文件说明

- `index.html`：问卷和统计看板
- `config.js`：云端连接与问卷名称配置
- `supabase-setup.sql`：数据库表、去重约束和访问权限
- `supabase-update-v2.sql`：旧版数据库增加集团培训及ACE认证字段
- `README.md`：部署说明
