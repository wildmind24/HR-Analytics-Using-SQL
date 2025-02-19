--- Data Cleaning


--- Checking for Duplicates in each table

SELECT birth_date, first_name, last_name, gender, hire_date, COUNT(*) 
FROM t_employees 
GROUP BY birth_date, first_name, last_name, gender, hire_date 
HAVING COUNT(*) > 1;

SELECT emp_no, dept_no, from_date, to_date, COUNT(*) 
FROM t_dept_manager 
GROUP BY emp_no, dept_no, from_date, to_date 
HAVING COUNT(*) > 1;

SELECT dept_no, dept_name, COUNT(*) 
FROM t_departments 
GROUP BY dept_no, dept_name 
HAVING COUNT(*) > 1;

SELECT emp_no, dept_no, from_date, to_date, COUNT(*) 
FROM t_dept_emp 
GROUP BY emp_no, dept_no, from_date, to_date 
HAVING COUNT(*) > 1;

SELECT emp_no, salary, from_date, to_date, COUNT(*) 
FROM t_salaries 
GROUP BY emp_no, salary, from_date, to_date 
HAVING COUNT(*) > 1;


--- Check for Missing Values

SELECT COUNT(*) AS missing_birth_dates FROM t_employees WHERE birth_date IS NULL;
SELECT COUNT(*) AS missing_dept_no FROM t_dept_emp WHERE dept_no IS NULL;


--- Check for Invalid Dates (e.g., Employees Hired Before Birth)

SELECT * 
FROM t_employees 
WHERE hire_date < birth_date;


--- Check for Employees Without Departments

SELECT emp_no 
FROM t_employees 
WHERE emp_no NOT IN (SELECT emp_no FROM t_dept_emp);


--- Identify Employees With Multiple Active Departments

SELECT emp_no, COUNT(DISTINCT dept_no) AS dept_count 
FROM t_dept_emp 
GROUP BY emp_no 
HAVING COUNT(DISTINCT dept_no) > 1;



--- Exploratory Data Analysis (EDA)


--- What is the gender distribution of employees?
--- What is the average age of employees?

SELECT gender, COUNT(*) AS count 
FROM t_employees 
GROUP BY gender;

SELECT YEAR(CURDATE()) - YEAR(birth_date) AS age, COUNT(*) AS count 
FROM t_employees 
GROUP BY age 
ORDER BY age;


--- Which department has the most employees?
--- Which department has the highest average salary?
--- Which department has the highest turnover rate?


SELECT d.dept_name, COUNT(e.emp_no) AS employee_count
FROM t_departments d
JOIN t_dept_emp de ON d.dept_no = de.dept_no
JOIN t_employees e ON de.emp_no = e.emp_no
GROUP BY d.dept_name;

SELECT d.dept_name, AVG(s.salary) AS avg_salary
FROM t_departments d
JOIN t_dept_emp de ON d.dept_no = de.dept_no
JOIN t_salaries s ON de.emp_no = s.emp_no
GROUP BY d.dept_name;

SELECT d.dept_name, COUNT(de.emp_no) AS total_employees,COUNT(de.to_date) AS total_left,(COUNT(de.to_date) / COUNT(de.emp_no)) * 100 AS turnover_rate
FROM t_departments d
JOIN t_dept_emp de ON d.dept_no = de.dept_no
GROUP BY d.dept_name;



--- What is the salary distribution across departments?
--- Who are the top 10 highest-paid employees?
--- What is the salary trend over time?

SELECT d.dept_name, MIN(s.salary) AS min_salary,MAX(s.salary) AS max_salary,AVG(s.salary) AS avg_salary
FROM t_salaries s
JOIN t_dept_emp de ON s.emp_no = de.emp_no
JOIN t_departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name
ORDER BY avg_salary DESC;

SELECT e.emp_no, e.first_name, e.last_name, s.salary
FROM t_employees e
JOIN t_salaries s ON e.emp_no = s.emp_no
ORDER BY s.salary DESC
LIMIT 10;

--- Average salary per year
SELECT YEAR(from_date) AS year,AVG(salary) AS avg_salary
FROM t_salaries
GROUP BY YEAR(from_date)
ORDER BY year;
--- To see salary trend by department
SELECT d.dept_name,YEAR(s.from_date) AS year,AVG(s.salary) AS avg_salary
FROM t_salaries s
JOIN t_dept_emp de ON s.emp_no = de.emp_no
JOIN t_departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name, YEAR(s.from_date)
ORDER BY year, dept_name;


--- Which departments have the highest attrition rates per departnent?
--- What is the trend of hiring over the years per departnent?

SELECT d.dept_name,YEAR(de.to_date) AS year,COUNT(DISTINCT de.emp_no) AS employees_left,(COUNT(DISTINCT de.emp_no) * 100.0) / (SELECT COUNT(DISTINCT emp_no) FROM t_employees) AS attrition_rate
FROM t_dept_emp de
JOIN t_departments d ON de.dept_no = d.dept_no
WHERE de.to_date < CURDATE()
GROUP BY d.dept_name, YEAR(de.to_date)
ORDER BY year, dept_name;

SELECT d.dept_name,YEAR(e.hire_date) AS year,COUNT(e.emp_no) AS employees_hired
FROM t_employees e
JOIN t_dept_emp de ON e.emp_no = de.emp_no
JOIN t_departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name, YEAR(e.hire_date)
ORDER BY year, dept_name;
