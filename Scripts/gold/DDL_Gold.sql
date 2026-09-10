/*
===========================================
DDL SCRIPT: Create Gold views
===========================================
Script purpose:
	This script crate views for golden layer in the data warehouse.
	The Gold layer represents the final dimension and fact tables(star schema)

=================================================================================
*/


IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers
GO

CREATE VIEW gold.dim_customers as 
select 
	ROW_NUMBER() OVER (order by cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as First_Name,
	ci.cst_lastname as Last_Name,
	la.cntry as Country,
	ci.cst_marital_status as Marital_status,
	CASE WHEN ci.cst_gndr!='N/A' THEN ci.cst_gndr -- CRM is the master table
		ELSE COALESCE(ca.gen,'N/A') 
	END as Gender,
	ca.bdate as Birth_date,
	ci.cst_create_date as Create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
ON ci.cst_key=la.cid;

GO

IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
	DROP VIEW gold.dim_products
GO

Create view gold.dim_products as
select
ROW_NUMBER() over (order by pn.prd_start_dt,pn.prd_key) as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id = pc.id
where prd_end_dt is null; --Filter out all historic data

GO

IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
	DROP VIEW gold.fact_sales
GO
CREATE VIEW gold.fact_sales as
select 
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity ,
sd.sls_price			
from silver.crm_sales_details sd
left join gold.dim_products pr
on sd.sls_prd_key= pr.product_number
left join gold.dim_customers cu
on sd.sls_cust_id = cu.customer_id;