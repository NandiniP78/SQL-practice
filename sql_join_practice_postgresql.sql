
-- DROP existing tables if any
DROP TABLE IF EXISTS Salaries;
DROP TABLE IF EXISTS EmployeeProjects;
DROP TABLE IF EXISTS Projects;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Departments;

-- Create tables
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100)
);

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10, 2),
    manager_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);

CREATE TABLE Projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);

CREATE TABLE EmployeeProjects (
    emp_id INT,
    project_id INT,
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

CREATE TABLE Salaries (
    emp_id INT,
    bonus DECIMAL(10, 2),
    date_given DATE,
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

-- Insert dummy data into Departments
INSERT INTO Departments VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Finance'),
(4, 'Marketing');

-- Insert dummy data into Employees
INSERT INTO Employees VALUES
(101, 'Alice', 1, 50000, NULL),
(102, 'Bob', 1, 55000, 101),
(103, 'Charlie', 2, 60000, 101),
(104, 'David', 2, 62000, 103),
(105, 'Eva', 3, 70000, 103),
(106, 'Frank', NULL, 45000, NULL);

-- Insert dummy data into Projects
INSERT INTO Projects VALUES
(201, 'Recruitment Drive', 1),
(202, 'Website Redesign', 2),
(203, 'Budget Planning', 3),
(204, 'Ad Campaign', 4);

-- Insert dummy data into EmployeeProjects
INSERT INTO EmployeeProjects VALUES
(101, 201),
(102, 201),
(103, 202),
(104, 202),
(105, 203);

-- Insert dummy data into Salaries (bonus records)
INSERT INTO Salaries VALUES
(101, 2000, '2024-12-01'),
(101, 2500, '2025-06-01'),
(102, 1800, '2024-11-15'),
(104, 2200, '2025-01-10'),
(105, 3000, '2025-03-20');


-- 🔰 Beginner Level (INNER JOIN)
-- Employees(emp_id, name, dept_id, salary,manager_id)
-- Departments(dept_id, dept_name)

--1. List all employees along with their department names.
select * from employees 
select * from departments

select e.*,d.dept_name
from employees e
join departments d
on e.dept_id = d.dept_id

--2. Find employees who work in the 'HR' department.
select e.*,d.dept_name
from employees e
join departments d
on e.dept_id = d.dept_id
where d.dept_name = 'HR'

--3. Show the names and salaries of employees who belong to the 'IT' department.
select e.name,e.salary,d.dept_name
from employees e
join departments d
on e.dept_id = d.dept_id
where d.dept_name = 'IT'

--4. List all departments and the number of employees in each.
select d.dept_name, count(*)
from employees e
join departments d
on e.dept_id = d.dept_id
group by d.dept_name

--5. Find employees who earn more than the average salary in their department.
SELECT e.name, e.salary
FROM Employees e
JOIN (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM Employees
    GROUP BY dept_id
) dept_avg ON e.dept_id = dept_avg.dept_id
WHERE e.salary > dept_avg.avg_salary;

--6. Get a list of department names and total salary paid in each.
SELECT d.dept_name, SUM(e.salary) AS total_salary
FROM Departments d
LEFT JOIN Employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

--7. Display only those departments that have at least one employee.
select d.dept_name, count(*) as total_employees
from departments d
join employees e on d.dept_id = e.dept_id
group by d.dept_name

-- 🧩 Intermediate Level (LEFT/RIGHT/FULL OUTER JOIN, SELF JOIN, MULTI-JOIN)
-- Projects(project_id, project_name, dept_id)
-- EmployeeProjects(emp_id, project_id)

--8. List all employees and the projects they are working on (including those without projects).
select e.name, p.project_name 
from employees e
left join employeeprojects ep on e.emp_id = ep.emp_id
left join projects p on ep.project_id = p.project_id

--9. Show all departments and the projects under them, even if some departments have no projects.
SELECT d.dept_name, p.project_name
FROM Departments d
LEFT JOIN Projects p ON d.dept_id = p.dept_id;

--10. Find employees who are not assigned to any project.
select e.emp_id, e.name, ep.project_id
from employees e
left join employeeprojects ep on e.emp_id = ep.emp_id
where ep.project_id is null

--11. List all projects and the number of employees working on each.
select p.project_name, count(*) as noOfEmployees
from projects p 
left join employeeprojects ep on p.project_id = ep.project_id
group by p.project_name

--12. List all employees who are working on more than one project.
select emp_id, count(*) as noOfProjects
from employeeprojects
group by emp_id
having count(*) > 1

--13. Show employees and their managers (use a self join on Employees).
select e.name as emp_name , m.name as manager_name
from employees e
left join employees m on (e.manager_id = m.emp_id)

--14. Get a list of all departments and include the department name even if it has no employees and no projects.
select distinct d.dept_name, 
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
--15. Write a query to show employees along with department and project name.
select e.name, d.dept_name, p.project_name
from employees e
left join departments d on e.dept_id = d.dept_id
left join projects p on d.dept_id = p.dept_id

-- 🧠 Advanced Level (CROSS JOIN, CTEs, Subqueries in JOINs, Set Ops)
--Salaries(emp_id, bonus, date_given)

--16. Get a list of employees with their latest bonus received.
SELECT *
FROM salaries s1
JOIN (SELECT emp_id, MAX(date_given) AS max_date
    FROM Salaries
    GROUP BY emp_id) s2
ON s1.emp_id = s2.emp_id AND s1.date_given = s2.max_date

--17. Find employees who have never received a bonus.
SELECT e.emp_id,e.name,s.bonus
FROM employees e
LEFT JOIN salaries s ON e.emp_id = s.emp_id
WHERE s.bonus IS NULL

--18. Show employees who work on all projects of their department.
SELECT e.emp_id, e.name
FROM Employees e
JOIN Projects p ON e.dept_id = p.dept_id
LEFT JOIN EmployeeProjects ep ON e.emp_id = ep.emp_id AND p.project_id = ep.project_id
GROUP BY e.emp_id, e.name
HAVING COUNT(DISTINCT p.project_id) = COUNT(DISTINCT ep.project_id);

--19. Use a CTE to find average bonus per employee and join it to show name, salary, and avg bonus.
with AvgBonus as
	(select emp_id, avg(bonus) as avg_bonus
	from salaries
	group by emp_id)
select e.name,e.salary,ab.avg_bonus
from employees e
left join AvgBonus ab on e.emp_id = ab.emp_id

--20. Create a full outer join to list all employee and department combinations (even if unrelated).
select *
from employees e
full outer join departments d on e.dept_id = d.dept_id

--21. Use a cross join to generate a report that shows every employee and every project (matrix).
SELECT e.name AS employee, p.project_name
FROM Employees e
CROSS JOIN Projects p;

--22. Identify employees who earn more than the highest paid employee in HR.
select *
from employees 
where salary > (select max(salary)
				from employees e
				join departments d on e.dept_id = d.dept_id
				where d.dept_name = 'HR' )

--23. For each department, find the employee with the highest bonus.
SELECT d.dept_name, e.name, s.bonus
FROM Salaries s
JOIN Employees e ON s.emp_id = e.emp_id
JOIN Departments d ON e.dept_id = d.dept_id
WHERE (e.emp_id, s.bonus) IN (
    SELECT e2.emp_id, MAX(s2.bonus)
    FROM Employees e2
    JOIN Salaries s2 ON e2.emp_id = s2.emp_id
    GROUP BY e2.dept_id
);

--24. Use INTERSECT to find employees who have both worked on Project A and Project B.
SELECT ep1.emp_id
FROM EmployeeProjects ep1
JOIN Projects p1 ON ep1.project_id = p1.project_id AND p1.project_name = 'Recruitment Drive'
INTERSECT
SELECT ep2.emp_id
FROM EmployeeProjects ep2
JOIN Projects p2 ON ep2.project_id = p2.project_id AND p2.project_name = 'Website Redesign';

--25. List employees who are in the same department and also work on the same projects (self join on both).
SELECT e1.name AS emp1, e2.name AS emp2, p.project_name
FROM Employees e1
JOIN Employees e2 ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
JOIN EmployeeProjects ep1 ON e1.emp_id = ep1.emp_id
JOIN EmployeeProjects ep2 ON e2.emp_id = ep2.emp_id AND ep1.project_id = ep2.project_id
JOIN Projects p ON ep1.project_id = p.project_id;


