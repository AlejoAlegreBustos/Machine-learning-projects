# Module #3 Report | CSE 310 – Applied Programming

|Alejo Alegre Bustos|11/03/2025|Bro. McGary|
|-|-|-|
| | | Bro McGary |

### Project Repository Link
[Github Repository](https://github.com/AlejoAlegreBustos/CSE-310/tree/main/personal-project/module-3)

### Module
Mark an **X** next to the module you completed

|Module                   | |Language                  | |
|-------------------------|-|--------------------------|-|
|Cloud Databases          | | Java                     | |
|Data Analysis            | | Kotlin                   | |
|Game Framework           | | R                        | |
|GIS Mapping              | | Erlang                   | |
|Mobile App               | | JavaScript               | |
|Networking               | | C#                       | |
|Web Apps                 | | TypeScript               | |
|Language – C++           | | Rust                     | |
|SQL Relational Databases | |Choose Your Own Adventure | |

### Fill Out the Checklist
Complete the following checklist to make sure you completed all parts of the module.  Mark your response with **Yes** or **No**.  If the answer is **No** then additionally describe what was preventing you from completing this step.

|Question                                                                                         |Your Response|Comments|
|--------------------------------------------------------------------------------------------------------------------|-|-|
|Did you implement the entire set of unique requirements as described in the Module Description document in I-Learn? |y| |
|Did you write at least 100 lines of code in your software and include useful comments?                              |y| |

[public DB supabase](https://supabase.com/dashboard/project/vhhusfbogsjknjsahfyy/database/schemas?schema=public)

<details>
<summary> schemas </summary>

```sql

-- Private schema

CREATE TABLE private_schema.model (
  model_id uuid NOT NULL DEFAULT gen_random_uuid(),
  last_release date NOT NULL,
  version text NOT NULL,
  algorithm_used text,
  n_estimators integer,
  max_depth integer,
  random_state integer,
  original_distribution jsonb,
  resampled_distribution jsonb,
  xgb_accuracy numeric,
  xgb_precision numeric,
  xgb_recall numeric,
  xgb_f1_score numeric,
  target text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT model_pkey PRIMARY KEY (model_id)
);

CREATE TABLE private_schema.user_priv (
  user_id uuid NOT NULL DEFAULT gen_random_uuid(),
  password text NOT NULL,
  date_of_birth date NOT NULL,
  email text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_priv_pkey PRIMARY KEY (user_id)
);


-- Public schema

CREATE TABLE public.report (
  reportid text NOT NULL,
  model-used text,
  version bigint,
  creation-date date,
  start-up-id text,
  report_url text,
  CONSTRAINT report_pkey PRIMARY KEY (reportid),
  CONSTRAINT report_start-up-id_fkey FOREIGN KEY (start-up-id) REFERENCES public.start-up(start-up-id)
);

CREATE TABLE public.start-up (
  start-up-id text NOT NULL,
  startup_name text,
  founded_year text,
  country text,
  region text,
  industry text,
  funding_round text,
  funding_amount_usd numeric,
  funding_date date,
  lead_investor text,
  co_investors text,
  employee_count bigint,
  estimated_revenue_usd numeric,
  estimated_valuation_usd numeric,
  exited text,
  exit_type text,
  tags text,
  CONSTRAINT start-up_pkey PRIMARY KEY (start-up-id)
);

CREATE TABLE public.user (
  user-id bigint NOT NULL,
  uname text,
  lname text,
  reportid text,
  CONSTRAINT user_pkey PRIMARY KEY (user-id),
  CONSTRAINT user_reportid_fkey FOREIGN KEY (reportid) REFERENCES public.report(reportid)
);
```

|Did you use the correct README.md template from the Module Description document in I-Learn?                         |Y| |
|Did you completely populate the README.md template?                                                                 |Y| |
|Did you create the video, publish it on YouTube, and reference it in the README.md file?                            |Y| |
|Did you publish the code with the README.md (in the top-level folder) into a public GitHub repository?              |Y| |
 

### Did you complete a Stretch Challenge 
If you completed a stretch challenge, describe what you completed.


### Record your time
How many hours did you spend on this module and the team project this Sprint?  
*Include all time including planning, researching, implementation, troubleshooting, documentation, video production, and publishing.*

|              |Hours|
|------------------|-|
|Individual Module |6|
|Team Project      |6|

### Retrospective
- What learning strategies worked well in this module?

  it is better to draft your database, functionalities, etc before to start coding it.

- What strategies (or lack of strategy) did not work well?

  for this module everything works well

- How can you improve in the next module?
  
  the next module will be more dificult, I'll be building some functionalities for the web/app, so I will need to start earlier than this module


[You Tube video](https://youtu.be/QoRnbdxCNT0)