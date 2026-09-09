
select prd_nm
from silver.crm_prd_info
where prd_nm!=TRIM(prd_nm)

select cst_lastname
from silver.crm_cust_info
where cst_lastname!=TRIM(cst_lastname)


select cst_gndr
from silver.crm_cust_info
where cst_lastname!=TRIM(cst_lastname)


select prd_id,count(1)
from silver.crm_prd_info
group by prd_id 
having count(1)>1 or prd_id is null


select prd_cost,count(1)
from silver.crm_prd_info
group by prd_cost 
having count(1)>1 or prd_cost is null

select * from silver.crm_prd_info

select *
from silver.crm_cust_info

--check for NULLS or negative values
select prd_cost
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null

--check data standardization and Consistency
select DISTINCT prd_line
from silver.crm_prd_info

--checkk for invalid date orders
select * 
from silver.crm_prd_info
where prd_start_dt > prd_end_dt

-- check data consistency between sales,quantity and price

select DISTINCT sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_details
where sls_sales!=sls_quantity* sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales<=0 or sls_quantity<=0 or sls_price<=0 
order by sls_sales, sls_quantity,sls_price


select * from 
silver.crm_sales_details
where sls_order_dt>sls_ship_dt or sls_order_dt>sls_due_dt

----------------------------------------------------------
select sls_price as old_price,sls_quantity,
CASE WHEN sls_sales is null or sls_sales<=0 or sls_sales!=sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END sls_sales,
CASE WHEN sls_price is null or sls_price<=0
		THEN sls_sales/NULLIF(sls_quantity,0)
	ELSE sls_price
END sls_price
from bronze.crm_sales_details
where sls_quantity>1
----------------------------------------------------------------------
--ERP TABLE
----------------------------------------------------------------------
select distinct 
gen
from silver.erp_cust_az12


select * from silver.erp_cust_az12 


select * from bronze.erp_px_cat_g1v2
where trim(maintenance)!=maintenance
