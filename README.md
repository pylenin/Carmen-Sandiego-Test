Welcome to Carmen Sandiego Project!

**Note** - The below model has been tested in Snowflake.

## Step 1

To read all the data from the excel, I have used a python script to load them into the `seeds` folder. Please check out `excel_to_csv.py`.

Once the CSV files are in the seed folder, I have used `dbt seed` command to load each of those CSVs as tables into my database. 

I have divided my tables into Staging, Dimension and Fact. Each of these tables are stored in their separate schema using the configuration below in `dbt_project.yml`.

```bash
models:
  carmen_sandiego:
    STAGING:
      +schema: CS_STG
    DIMENSION:
      +schema: CS_DIM
    DIMENSION:
      +schema: CS_FACT
```

## Step 2

I have built a macro called `add_column_names.sql` to columnarly maps the eight different sources into the provided data dictionary and loading each source as `STG_{REGION}.csv`. I have defined the data dictionary in another macro called `desired_column_names.sql`. You can find the macros inside the macro folder.

**Note** - The data dictionary could also be defined as a variable. I chose to go with a macro.

## Step 3

I have combined all the region data into one file called `STG_ALL_GEO.sql` int he STAGING folder. From there I have normalized the dataset into the three necessary views.

1. DIM_ATTRIBUTES.sql
2. DIM_BEHAVIOR.sql
3. DIM_COUNTRY.sql

## Analytics

The analytical views are created in the FACT folder. usually the last bit of calculations go into a BI tool. In my experience, I don't add mathematical formulas or store results as part of the dbt models. This allows Data Analysts to perform their own mathematical calculations on top of the FACT tables.

1. For each month, which agency region is Carmen Sandiego most likely to be found?

```sql
    WITH BASE AS (
    SELECT *, ROW_NUMBER() over (PARTITION BY WITNESS_MONTH ORDER BY NUM_OF_SIGHTINGS DESC) AS RANK
    FROM {{ref('FACT_GEOGRAPHY')}}
    )
    SELECT *
    FROM BASE WHERE RANK = 1;
```

2. For each month, what is the probability that Ms. Sandiego is armed AND wearing a jacket, but NOT a hat? What general observations about Ms. Sandiego can you make from this?

```sql
with base as (
    select date_trunc('MONTH', date_witness) as witness_month, date_witness, attribute_match 
    from {{ref('FACT_ATTRIBUTE_MATCH')}} 
    )
    select witness_month, sum(case when attribute_match = 'MATCH' THEN 1 else 0 end)/count(*) as probability_of_match from base group by 1 order by 1;
```

3. What are the three most occuring behaviors of Ms. Sandiego?

```sql
    select BEHAVIOR, COUNT(*)
    from {{ref('FACT_BEHAVIOR')}}
    GROUP BY 1
    ORDER BY 2 DESC LIMIT 3;
```

4. For each month, what is the probability Ms. Sandiego exhibits one of her three most occurring behaviors?

```sql
    with behavior as (
    select BEHAVIOR
    from DATAFLO_ETLDB_DEV.DEV_PRE_AGGREGATION.FACT_BEHAVIOR
    GROUP BY 1
        order by count(*) desc limit 3
    ),
    witness_behavior as (
    select *
        from DATAFLO_ETLDB_DEV.DEV_PRE_AGGREGATION.FACT_BEHAVIOR
    )
    select date_trunc('MONTH', date_witness) as witness_month,
    sum(case when b.behavior is not null then 1 else 0 end)/count(wb.behavior) as prob
    from witness_behavior wb 
    left join behavior b on wb.behavior = b.behavior
    group by 1 order by 1;
```