CREATE DATABASE employee_attrition;
USE employee_attrition;
CREATE TABLE attrition(Age int(2),
						Attrition VARCHAR(3),
						BusinessTravel VARCHAR(17),
						DailyRate int(4),
                        Department VARCHAR(22),
                        DistanceFromHome int(2),
                        EducationLevel int(1),
                        EducationField VARCHAR(16),
                        EmployeeCount int(1),
                        EmployeeNumber int(4),
                        EnvironmentSatisfaction	int(2),
                        Gender VARCHAR(6),
                        HourlyRate int(3),
                        JobInvolvement int(1),
                        JobLevel int(1),
                        JobRole	VARCHAR(25),
                        JobSatisfaction	int(1),
                        MaritalStatus VARCHAR(8),
                        MonthlyIncome int(4),
                        MonthlyRate int(5),
                        NumCompaniesWorked int(2),
                        Over18 VARCHAR(3),
                        OverTime VARCHAR(3),
                        PercentSalaryHike int(2),
                        PerformanceRating int(1),
                        RelationshipSatisfaction int(1),
                        StandardHours int(2),
                        StockOptionLevel int(1),
                        TotalWorkingYears int(2),
                        TrainingTimesLastYear int(1),
                        WorkLifeBalance	int(1),
                        YearsAtCompany	int(2),
                        YearsInCurrentRole	int(2),
                        YearsSinceLastPromotion	int(2),
                        YearsWithCurrManager int(2));
 Select * from attrition; 
 
 # 1. which three department have the highest attrition rate, highest to lowest?
 
Select Department, COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)/count(*) as attrition_rate from attrition
group by Department
order by attrition_rate desc
limit 3;

# 2. Of those who left the company, what percentage of those had a wage less than the average of wages by their department?

with avg_income as (
	select Department as dept, avg(MonthlyIncome) as average_income from attrition
	group by Department),
attrition_below as (select a.department, count(*) as amount from attrition a
left join avg_income i
on a.Department = i.dept
where attrition = 'Yes' and monthlyIncome < average_income
group by department),
department_counts as (select department, count(*) as counts from attrition where attrition = 'yes' group by department)
select b.department, round((b.amount/d.counts), 2)*100 as percentage_attrionedEmp_less_than_average
from attrition_below b
left join department_counts d
on b.department = d.department
order by percentage_attrionedEmp_less_than_average desc; 
    
# 3. what’s the avergae tenure of those who left and those who are currently working? - MAYBE LOOK AT ADDING YEAR STRING 10/28

select (select Round(avg(YearsAtCompany), 2) as avg_tenure
from attrition 
where attrition = 'No') as avg_retained_employee_tenure, (select Round(avg(YearsAtCompany), 2) as avg_tenure
from attrition
where attrition = 'Yes') as avg_attritioned_employee_tenure;

# 4. What's the average amount of companies someone who left vs someone who is still working?

select (select Round(avg(NumCompaniesWorked), 2) as avg_num_companies
from attrition 
where attrition = 'No') as avg_number_companies_worked_retained, (select Round(avg(NumCompaniesWorked), 2) as avg_num_companies
from attrition
where attrition = 'Yes') as avg_companies_worked_attritioned;

# GO BACK 5. What percentage of employees that were retained and left had a pay hike lower than the average pay hike for all employees?

with attrition_below_avg as (select count(*) as counts from attrition
where attrition = 'Yes' and PercentSalaryHike < (select avg(PercentSalaryHike) from attrition)),
retention_below_avg as (select count(*) as counts from attrition
where attrition = 'No' and PercentSalaryHike < (select avg(PercentSalaryHike) from attrition ))
select ((select counts from attrition_below_avg)/(count(*)))*100 as percentage_attritioned_below_avg, ((select counts from retention_below_avg)/(count(*)))*100 as percentage_retention_below_avg
from attrition;

# 6. Rank the Field's of study by highest count of attrition desc

with rates as (select EducationField, COUNT(case when Attrition = 'Yes' then 1 end)/count(*) as percentage_rates from attrition group by EducationField order by percentage_rates desc) 
select EducationField, percentage_rates, dense_rank() over (order by percentage_rates desc) as rankings
from rates
order by percentage_rates desc;

# 7. What's the average age of someone who has left the company? Average age of those who did not?

select (select avg(Age) from attrition where Attrition = 'Yes') as avg_attritioned_age,
(select avg(Age) from attrition where Attrition = 'No') as avg_retained_age;

# 8. What percentage of employees who did not leave the company have a leadership role?

Select round((select count(*) from attrition where Attrition = 'Yes' and (JobRole like '%manager%' or JobRole like '%director%' or JobRole like '%executive%'))/(select count(*) from attrition)*100, 2) as percentage_of_attritioned_employees_in_leadership;

# GO BACK 10/29 9. Rank all the tenure of employees by highest attrition rates

With tenure_rates as (select YearsAtCompany, Count(case when attrition = 'yes' then 1 end)/count(*) as attrition_rates
from attrition
group by 1
order by 1)
select YearsAtCompany, attrition_rates, dense_rank() over(order by attrition_rates desc) as rankings from tenure_rates;

# 10. Spread of females vs males who are satisfied with their jobs

select Gender, SUM(case when JobSatisfaction >= 3 then 1 else 0 end)/count(*)*100 as job_satisfaction_rate from attrition
group by Gender;

# 11. Rank travel categories by average job satisfaction per cat

With satisfaction_levels as (select BusinessTravel, Round(avg(JobSatisfaction), 2) as avg_satisfaction from attrition
group by 1
order by avg_satisfaction desc)
select BusinessTravel, avg_satisfaction, rank() Over(order by avg_satisfaction desc) as ranks
from satisfaction_levels;

# 12. What percentage of those attritioned were married and not married?

select (select count(*) from attrition where attrition = 'yes' and MaritalStatus = 'Married')/count(*)*100 as Married_percentage_attritioned,
(select count(*) from attrition where attrition = 'yes' and MaritalStatus = 'Divorced')/COUNT(*)*100 as Divorced_percentage_attritioned,
(select count(*) from attrition where attrition = 'yes' and MaritalStatus = 'Single')/COUNT(*)*100 as Single_percentage_attritioned 
from attrition where attrition = 'yes';

