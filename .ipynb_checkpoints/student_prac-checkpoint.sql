use prac_school;

show tables;

-- 创建学生表
create table Student(SId varchar(10),Sname varchar(10),Sage datetime,Ssex varchar(10));
insert into Student values('01' , '赵雷' , '1990-01-01' , '男');
insert into Student values('02' , '钱电' , '1990-12-21' , '男');
insert into Student values('03' , '孙风' , '1990-12-20' , '男');
insert into Student values('04' , '李云' , '1990-12-06' , '男');
insert into Student values('05' , '周梅' , '1991-12-01' , '女');
insert into Student values('06' , '吴兰' , '1992-01-01' , '女');
insert into Student values('07' , '郑竹' , '1989-01-01' , '女');
insert into Student values('09' , '张三' , '2017-12-20' , '女');
insert into Student values('10' , '李四' , '2017-12-25' , '女');
insert into Student values('11' , '李四' , '2012-06-06' , '女');
insert into Student values('12' , '赵六' , '2013-06-13' , '女');
insert into Student values('13' , '孙七' , '2014-06-01' , '女');

select * from student;

-- 创建科目表
create table Course(CId varchar(10),Cname nvarchar(10),TId varchar(10));
insert into Course values('01' , '语文' , '02');
insert into Course values('02' , '数学' , '01');
insert into Course values('03' , '英语' , '03');

select * from course;

-- 创建教师表
create table Teacher(TId varchar(10),Tname varchar(10));
insert into Teacher values('01' , '张三');
insert into Teacher values('02' , '李四');
insert into Teacher values('03' , '王五');

-- 创建成绩表
create table SC(SId varchar(10),CId varchar(10),score decimal(18,1));
insert into SC values('01' , '01' , 80);
insert into SC values('01' , '02' , 90);
insert into SC values('01' , '03' , 99);
insert into SC values('02' , '01' , 70);
insert into SC values('02' , '02' , 60);
insert into SC values('02' , '03' , 80);
insert into SC values('03' , '01' , 80);
insert into SC values('03' , '02' , 80);
insert into SC values('03' , '03' , 80);
insert into SC values('04' , '01' , 50);
insert into SC values('04' , '02' , 30);
insert into SC values('04' , '03' , 20);
insert into SC values('05' , '01' , 76);
insert into SC values('05' , '02' , 87);
insert into SC values('06' , '01' , 31);
insert into SC values('06' , '03' , 34);
insert into SC values('07' , '02' , 89);
insert into SC values('07' , '03' , 98);

select * from sc;

-- 题目 --

-- 1.查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
select student.sid, student.sname, student.ssex, student.sage, r.class1, r.class2 from 
	student 
    right join(
		select c1.sid, class1, class2 from
			(select sid, score as class1 from sc where cid = 1) as c1,
			(select sid, score as class2 from sc where cid = 2) as c2
		where c1.sid = c2.sid and c1.class1 > c2.class2
	) as r
	on student.sid = r.sid;

-- 2.查询同时存在" 01 "课程和" 02 "课程的情况
select t1.sid from (
		(select sid from sc where cid = '01') as t1
		inner join
		(select sid from sc where cid = '02') as t2
		on t1.sid = t2.sid
    );

-- 3.查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )
select t1.sid, class1, class2 from (
	(select sid, score as class1 from sc where cid = '01') as t1
    left join
    (select sid, score as class2 from sc where cid = '02') as t2
    on t1.sid = t2.sid
);
    
-- 4.查询不存在" 01 "课程但存在" 02 "课程的情况
select t2.sid, class1, class2 from (
	(select sid, score as class2 from sc where cid = '02') as t2
    left join
    (select sid, score as class1 from sc where cid = '01') as t1
    on t2.sid = t1.sid
) where class1 is null;
    
-- 5.查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
select avsc.sid, student.sname, avsc.avg_score from
	student 
    right join 
	(select sid, avg(score) as avg_score from sc group by sid having avg_score > 60) as avsc 
    on student.sid = avsc.sid;

-- 6.查询在 SC 表存在成绩的学生信息
select * from student where sid in (select distinct sid from sc);

-- 7.查询所有同学的学生编号、学生姓名、选课总数、所有课程的成绩总和
select student.sid, student.sname, t.count_class, t.sum_score from student left join(
	select sid, count(cid) as count_class, sum(score) as sum_score from sc group by sid
) as t
on student.sid = t.sid;

-- 8.查询「李」姓老师的数量
select count(*) as '李姓老师的数量' from teacher where tname like '李%';

-- 9.查询学过「张三」老师授课的同学的信息
select * from student where sid in (
	select sid from sc where cid in (
		(select course.cid from course, teacher where course.tid = teacher.tid and teacher.tname = '张三')
        )
	);

select student.* from student, course, teacher, sc
	where	
		student.sid = sc.sid
	and	course.cid = sc.cid
	and course.tid = teacher.tid
	and teacher.tname = '张三';

-- 10.查询没有学全所有课程的同学的信息
select * from student where sid in 
	(select sid from sc group by sid having count(distinct cid) < 3);

-- 11.查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
select * from student where sid in
(select distinct sid from 
	(select * from sc where cid in
		(select cid from sc where sid = '01')
		and sid <> '01') as ss);
        
-- 12.查询和" 01 "号的同学学习的课程完全相同的其他同学的信息
select * from student where sid in (
	select sid from (
		select sid, group_concat(cid order by cid) as cids from sc group by sid having sid <> '01'
    )as t1
	where cids = (
        select group_concat(cid order by cid) from sc where sid = '01'
    )
);

select * from student where sid in (
	select sid from sc where sid <> '01' group by sid having group_concat(cid order by cid) = (
		select group_concat(cid) from sc where sid = '01' group by sid
    )
);

-- 13.查询没学过"张三"老师讲授的任一门课程的学生姓名
select sname from student where sid not in (
	select distinct sc.sid from sc, course, teacher 
		where sc.cid = course.cid
        and course.tid = teacher.tid
        and teacher.tname = '张三'
);

-- 14..查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
select student.sid, student.sname, avgs.avg_score from student right join (
	select sid, avg(score) as avg_score from sc group by sid having sid in (
		select sid from sc where score < 60 group by sid having count(cid) >= 2
    ) 
) as avgs on student.sid = avgs.sid;

-- 15.检索" 01 "课程分数小于 60，按分数降序排列的学生信息
select student.*, t.cid, t.score from 
	student,
    (select * from sc where score < 60 and cid = '01') as t
    where student.sid = t.sid
    order by t.score desc;
    
-- 16.按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
select *  from 
	sc 
	left join 
    (
		select sid,avg(score) as avscore from sc 
		group by sid
    ) as r
	on sc.sid = r.sid
	order by avscore desc;
    
-- 17.查询各科成绩最高分、最低分和平均分
-- 以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
-- 及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
-- 要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
select 
	course.cname as '课程名称',
    t.*
    from (
	select 
		cid as '课程ID',
		max(score) as '最高分',
		min(score) as '最低分',
		avg(score) as '平均分',
		count(sid) as '选课人数',
        avg(case when score>=60 then 1 else 0 end) as '及格率',
        avg(case when score>=70 then 1 else 0 end) as '中等率',
        avg(case when score>=80 then 1 else 0 end) as '优良率',
        avg(case when score>=90 then 1 else 0 end) as '优秀率'
	from sc group by cid
)as t left join course on t.课程ID = course.cid
order by 选课人数 desc, 课程ID asc;

-- 18.按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺
select a.cid, a.sid, a.score, count(b.score) + 1 as ranking from sc as a
left join sc as b on a.cid = b.cid and a.score < b.score
group by a.cid, a.sid
order by cid asc, ranking asc;

-- 19.查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
select student.*, t.total_score, t.ranking from student right join
	(
	select a.sid, a.total_score, count(b.total_score) + 1 as ranking from
		(select sid, sum(score) as total_score from sc group by sid) as a
	left join
		(select sid, sum(score) as total_score from sc group by sid) as b
	on a.total_score < b.total_score
	group by sid
	) as t
    on student.sid = t.sid
    order by ranking asc;
    
-- 20.查询学生的总成绩，并进行排名，总分重复时不保留名次空缺

with t as (select sid, sum(score) as total_score from sc group by sid)
select student.*, t.total_score, row_number() over (order by t.total_score desc) as ranking
from student left join t on student.sid = t.sid
order by ranking;

-- 21.统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
with t as (
	select 
		cid as '课程ID',
		avg(case when score <= 100 and score > 85 then 1 else 0 end) as '85-100分比例',
        avg(case when score <= 85 and score > 70 then 1 else 0 end) as '70-85分比例',
        avg(case when score <= 75 and score > 60 then 1 else 0 end) as '60-70分比例',
        avg(case when score <= 60 then 1 else 0 end) as '<=60分比例'
	from sc group by cid
)
select course.cname as '课程名称', t.* from t left join course on course.cid = t.课程ID;

-- 22.查询各科成绩前三名的记录
with t as (
(select * from sc where cid = '01' order by score desc limit 3)
union
(select * from sc where cid = '02' order by score desc limit 3)
union
(select * from sc where cid = '03' order by score desc limit 3)
)
select t.cid, t.sid, student.sname, student.ssex, t.score
from t left join student on t.sid = student.sid
order by cid asc, score desc;

-- 23.查询每门课程被选修的学生数
select sc.cid, course.cname, count(sc.sid) as stu_inclass
from sc left join course on sc.cid = course.cid
group by sc.cid;

-- 24.查询出只选修两门课程的学生学号和姓名
with t as (
select sid, count(cid) as course_count from sc group by sid having course_count = 2
)
select student.*, t.course_count
from t join student on t.sid = student.sid;

-- 25.查询男生、女生人数
select ssex, count(sid) as sex_count
from student
group by ssex;

-- 26.查询名字中含有「风」字的学生信息
select * from student where sname like '%风%';

-- 27.查询同名学生名单，并统计同名人数
select sname, count(sid) as num_students
from student
group by sname
having num_students > 1;

-- 28.查询 1990 年出生的学生名单
select sid, sname, ssex, extract(year from sage) as year_of_birth from student having year_of_birth = '1990';

-- 29.查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
with t as (
select cid, avg(score) as avg_score from sc group by cid
)
select t.cid, c.cname, t.avg_score 
from t left join course as c on t.cid = c.cid
order by avg_score desc, cid asc;

-- 30.查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩
with t as (
	select sid, avg(score) as avg_score from sc group by sid having avg_score >= 85
)
select student.*, t.avg_score 
from t left join student
on student.sid = t.sid;

-- 31.查询课程名称为「数学」，且分数低于 60 的学生姓名和分数
with 
t as (
	select * from sc where cid = (select cid from course where cname = '数学') and score < 60
)
select student.sname, t.score 
from t left join student
on t.sid = student.sid;

select student.sname, sc.score 
from student, course, sc
where 
	course.cname = '数学'
	and course.cid = sc.cid
    and sc.sid = student.sid
    and sc.score < 60;
    
-- 32.查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）
with t as (
	select student.sid, student.sname, sc.cid, sc.score
    from student left join sc on student.sid = sc.sid
)
select t.sid, t.sname, t.cid, course.cname, t.score
from t left join course on t.cid = course.cid;

-- 33.查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
select student.sname, course.cname, sc.score
from student, sc, course
	where student.sid = sc.sid
    and sc.cid = course.cid
    and sc.score >= 70;
    
-- 34.查询存在不及格的课程
with t as (
	select distinct cid from sc where score < 60
)
select t.cid, course.cname from t left join course on t.cid = course.cid;

select cname from course where cid in (
	select distinct cid from sc where score < 60
);

-- 35.查询课程编号为 01 且课程成绩在 80 分及以上的学生的学号和姓名
select student.sid, student.sname 
from student, sc
	where cid = '01'
	and student.sid = sc.sid
    and sc.score >= 80;
    
-- 36.求每门课程的学生人数
select cid, count(sid) as num_of_students from sc group by cid;

-- 37.成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
select student.*, sc.cid, sc.score from student, sc
	where sc.sid = student.sid
    and cid in (
		select cid from course where tid = (
			select tid from teacher where tname = '张三'
        )
    )
    order by score desc limit 1;

select student.*, sc.score from student, sc, course, teacher
	where sc.cid = course.cid
    and sc.sid = student.sid
    and teacher.tid = course.tid
    and teacher.tname = '张三'
order by score desc
limit 1;

-- 38.成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
select student.*, sc.score from student, sc, course, teacher
	where sc.cid = course.cid
    and sc.sid = student.sid
    and course.tid = teacher.tid
    and teacher.tname = '张三'
    and score = (
		select max(score) from sc where cid = (
			select cid from course where tid = (
				select tid from teacher where tname = '张三'
			)
        )
    );

-- 39.查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
with t as (with 
	t0 as (select distinct sid from sc),
	t1 as (select sid, score as class01 from sc where cid = '01'),
	t2 as (select sid, score as class02 from sc where cid = '02'),
	t3 as (select sid, score as class03 from sc where cid = '03')
	select t0.sid, t1.class01, t2.class02, class03
	from
		t0 left join t1 on t0.sid = t1.sid
		left join t2 on t0.sid = t2.sid
		left join t3 on t0.sid = t3.sid
)
select sid, cid, score from sc where sid in (
	select sid from t 
		where class01 = class02
        or class02 = class03
        or class01 = class03
);

-- 40.查询每门功成绩最好的前两名
with t as (
	(select * from sc where cid = '01' order by score desc limit 2)
    union
    (select * from sc where cid = '02' order by score desc limit 2)
    union
    (select * from sc where cid = '03' order by score desc limit 2)
)
select t.cid, t.score, student.* from t left join student on t.sid = student.sid order by cid asc, score desc;

-- 41.查询选修了全部课程的学生信息
with t as (
	select sid, count(cid) as num_courses from sc group by sid having num_courses = (
		select count(distinct cid) from course
	)
)
select student.*, t.num_courses from student, t
	where student.sid = t.sid;
    
-- 42.查询各学生的年龄，精确到天数
select student.sname, timestampdiff(day, student.sage, curdate()) as '年龄(天)' from student;

-- 43.查询本月过生日的学生
select * from student where month(sage) = month(curdate())