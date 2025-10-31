# SQL-HR-Attrition-Data-Analysis-project
![HR picture]([SQL-HR-Attrition-Data-Analysis-project/Employee-Attrition.jpg](https://github.com/alashaym/SQL-HR-Attrition-Data-Analysis-project/blob/main/Employee-Attrition.jpg))

## overview
The objective of this project is to extract valuable insights about IBM HR attrition data using MYSQL data analysis techniques. The purpose of this project is to identify key factors that have contributed to employee turnover rates. Using problem-solving skills and utilizing SQL queries, factors such as Martial Status, compensation and Job Roles have been analyzed to determine what factors are correlated with increased tunrover rates. This project demonstrates how data-driven insights can support strategic HR decision-making and improve employee retention

## Objectives 
    - analyze the distribution of attrition rates across Job role, Departments, and Tenure\
    - Determine the impact that raises have on employee retention
    - rank and categorize data based on specific critera
    - Determine the most influencial factors in employee attrition rates

## Data set 
Dataset Link: https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset

## Schema 
```sql
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
```

## Business Problems 
### 1. which three department have the highest attrition rate, in order?
```sql
Select Department, COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)/count(*) as attrition_rate from attrition
group by Department
order by attrition_rate desc
limit 3;
```
#### objective: determine which departments experience the highest rates of attrition 

### 2. Of those who left the company, what percentage of those had a wage less than the average of wages by their department?
```sql
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
```
#### objective: determine if wages have an impact on rates of attrition

### 3. what’s the avergae tenure of those who left and those who are currently working? 
```sql
select (select Round(avg(YearsAtCompany), 2) as avg_tenure
from attrition 
where attrition = 'No') as avg_retained_employee_tenure, (select Round(avg(YearsAtCompany), 2) as avg_tenure
from attrition
where attrition = 'Yes') as avg_attritioned_employee_tenure;
```
#### objective: determine if there is a difference in average tenure between those who left the company and those currently working

### 4. What's the average amount of companies someone who left vs someone who is still working?
```sql
select (select Round(avg(NumCompaniesWorked), 2) as avg_num_companies
from attrition 
where attrition = 'No') as avg_number_companies_worked_retained, (select Round(avg(NumCompaniesWorked), 2) as avg_num_companies
from attrition
where attrition = 'Yes') as avg_companies_worked_attritioned;
```
#### objective: Is there a higher average for those who left the company vs those who weren't attritioned. This may indicate if there
#### is a factor outside of the company's control in rates of attrition

### 5. What percentage of employees that were retained and left had a pay hike lower than the average pay hike for all employees?
```sql
with attrition_below_avg as (select count(*) as counts from attrition
where attrition = 'Yes' and PercentSalaryHike < (select avg(PercentSalaryHike) from attrition)),
retention_below_avg as (select count(*) as counts from attrition
where attrition = 'No' and PercentSalaryHike < (select avg(PercentSalaryHike) from attrition ))
select ((select counts from attrition_below_avg)/(count(*)))*100 as percentage_attritioned_below_avg, ((select counts from retention_below_avg)/(count(*)))*100 as percentage_retention_below_avg
from attrition;
```
#### objective: Determine whether the pay raise an individual recieves has an impact on employee attrition rates

### 6. Rank the Field's of study by highest count of attrition desc
```sql
with rates as (select EducationField, COUNT(case when Attrition = 'Yes' then 1 end)/count(*) as percentage_rates from attrition group by EducationField order by percentage_rates desc) 
select EducationField, percentage_rates, dense_rank() over (order by percentage_rates desc) as rankings
from rates
order by percentage_rates desc;
```
#### objective: Determine if different fields of study have historically higher or lower attrition rates. This could be linked to other factors
#### such as average incomes by fields of study

### 7. What's the average age of someone who has left the company? Average age of those who did not?
```sql
select (select avg(Age) from attrition where Attrition = 'Yes') as avg_attritioned_age,
(select avg(Age) from attrition where Attrition = 'No') as avg_retained_age;
```
#### objective: Determine if there is a trend with employees age and their attrition rates. This could indicate that attrition rates
#### are not are a result of company processes and could be linked to old age (retirement) or early career building for younger individuals. 

### 8. What percentage of employees who did not leave the company have a leadership role?
```sql
Select round((select count(*) from attrition where Attrition = 'Yes' and (JobRole like '%manager%' or JobRole like '%director%' or JobRole like '%executive%'))/(select count(*) from attrition)*100, 2) as percentage_of_attritioned_employees_in_leadership;
```
#### objective: Determine if heirarchical status has an impact on attrition rates. The results of this could indicate
#### if the company gives a strong sense of responsibilty and empowerment and opportunity to those outside of leadership positions.

### 9. Rank all the tenure of employees by highest attrition rates
```sql
With tenure_rates as (select YearsAtCompany, Count(case when attrition = 'yes' then 1 end)/count(*) as attrition_rates
from attrition
group by 1
order by 1)
select YearsAtCompany, attrition_rates, dense_rank() over(order by attrition_rates desc) as rankings from tenure_rates;
```
#### objective: Determine if tenure has an impact on attrition rates. This question helps determine commmitment and comfortability of 
#### employees at the company. 

### 10. Spread of females vs males who are satisfied with their jobs
```sql
select Gender, SUM(case when JobSatisfaction >= 3 then 1 else 0 end)/count(*)*100 as job_satisfaction_rate from attrition
group by Gender;
```
#### objective: Determine if the company is employing fair practicing and treatment on the basis of gender by measuring satisfaction rates. 

### 11. Rank travel categories by average job satisfaction per cat
```sql
With satisfaction_levels as (select BusinessTravel, Round(avg(JobSatisfaction), 2) as avg_satisfaction from attrition
group by 1
order by avg_satisfaction desc)
select BusinessTravel, avg_satisfaction, rank() Over(order by avg_satisfaction desc) as ranks
from satisfaction_levels;
```
#### objective: Determine if rate of travel for the company has an impact on attrition rates. This could determine the restructuring 
#### of travel within the company if there is big gap between satisaction levels and attrition rates. 

### 12. What percentage of those attritioned were married and not married?
```sql
select (select count(*) from attrition where attrition = 'yes' and MaritalStatus = 'Married')/count(*)*100 as Married_percentage_attritioned,
(select count(*) from attrition where attrition = 'yes' and MaritalStatus = 'Divorced')/COUNT(*)*100 as Divorced_percentage_attritioned,
(select count(*) from attrition where attrition = 'yes' and MaritalStatus = 'Single')/COUNT(*)*100 as Single_percentage_attritioned 
from attrition where attrition = 'yes';
```
#### objective: Determine if Marital status has an impact on attrition rates. This question can help IBM determine if there
#### is a factor that is outside of their control that results in higher or lower attrition rates. 

## Findings and Conclusions:
  - Leadership roles may impact whether an individual is attritioned as only 5% of attritioned employees had a leadership role
  - Job satisfaction rates between Females and Males are similarly distributed at 59.7% and 62.4%, respectively
  - Travel rates don't tend to impact Job satisfaction rates, with all rates between 2.7 and 2.8 out of 5 for all categories
  - Marital status does imply an impact on attrition rates, with 50% of those being attritioned identifying at Single and 35 % identifying as married.
  - A majority (70 - 90%) of those who were attritioned had an average salary less than the average salary of their departments. This indicates that salary
    has a major impact on whether or not someone leaves the company. 





