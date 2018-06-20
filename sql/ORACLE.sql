---1(1)
select count(*)
from (select msisdn,sum(a.pv) pv_count
from pagevisit a,user_info b
where a.msisdn=b.msisdn
and b.sex='男'
and a.record_day>='20171001'
and a.record_day<='20171007'
group by a.msisdn) x
where x.pv_count>100;

----1(2)
--建日期表
create table day_list 
(
record_day varchar2(10)
) COMPRESS NOLOGGING PCTFREE 0;

select * 
from day_list for update;
 commit;

create table temp1 as
select x.msisdn,y.record_day
from  (select distinct msisdn
from pagevisit a
where a.record_day>='20171001'
and a.record_day<='20171007') x,day_list y;

create table temp2 as
select a.*,case when b.mp is not null then '1' else '0' end if_pv
from  temp1 a, (select  msisdn||record_day mp
from pagevisit
where record_day>='20171001'
and record_day<='20171007') b
where a.msisdn||a.record_day=b.mp(+);

create table temp3 as  
  select msisdn,listagg(if_pv) within GROUP (ORDER BY record_day asc) pv_LIST
  FROM temp 2
  GROUP BY msisdn;
  
  select msisdn
  from temp3 
  where pv_LIST like '%111%';


----2(1)
select  c.dept_name,a.name,a.salary
from EMPLOYEE a,(select salary,departmentid,rn
from (select salary,departmentid,ROW_NUMBER() OVER  (PARTITION BY departmentid  ORDER BY salary desc) rn
from (select distinct salary,departmentid
from EMPLOYEE))
where rn=3) b,DEPARTMENT c
where a.departmentid=b.departmentid
and a.salary<=b.salary
and a.departmentid=c.departmentid;

----3(1)
create table temp as
select a.*,b.BANNED BANNED_C,c.BANNED BANNED_D
from TRIPS a,USERS b,USERS c
where a.CLIEND_ID=b.USER_ID
and a.DRIVER_ID=c.USER_ID
and to_date(a.REQUEST_AT,'yyyy-mm-dd')>=to_date('20131001','yyyymmdd')
and to_date(a.REQUEST_AT,'yyyy-mm-dd')<to_date('20131003','yyyymmdd');

select REQUEST_AT,round(count(*)/count(case when if_qx='1' then userid else null end),2)
from (select REQUEST_AT,CLIEND_ID userid,case when STATUS='CANCELLED_BY_CLIENT' then '1' else '0' end if_qx
from temp
where BANNED BANNED_C='No'
union all
select REQUEST_AT,DRIVER_ID userid,case when STATUS='CANCELLED_BY_DRIVER' then '1' else '0' end if_qx
from temp
where BANNED BANNED_D='No') x
group by REQUEST_AT;
