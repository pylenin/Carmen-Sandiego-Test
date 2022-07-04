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
    FACT:
      +schema: CS_FACT
```

## Step 2

I have built a macro called `add_column_names.sql` to columnarly maps the eight different sources into the provided data dictionary and loading each source as `STG_{REGION}.csv`. I have defined the data dictionary in another macro called `desired_column_names.sql`. You can find the macros inside the macro folder.

**Note** - The data dictionary could also be defined as a variable. I chose to go with a macro.

## Step 3

I have combined all the region data into one file called `STG_ALL_GEO.sql` int he STAGING folder. From there I have normalized the dataset into the 6 necessary views. 

1. DIM_ATTRIBUTES.sql
2. DIM_BEHAVIOR.sql
3. DIM_COUNTRY.sql
4. DIM_AGENT.sql
5. DIM_CITY.sql
6. DIM_WITNESS.sql

Here is the ERD diagram.

![ERD diagram](https://user-images.githubusercontent.com/44732615/177209755-5e73b303-78fc-4e2a-9faf-28427e670a22.png)


Overall the dbt model looks like the below image.

![Screenshot from 2022-07-05 01-09-47](https://user-images.githubusercontent.com/44732615/177209918-45970a22-2f54-406d-82b0-273e9f874546.png)


## Analytics

The analytical views are created in the FACT folder. usually the last bit of calculations go into a BI tool. In my experience, I don't add mathematical formulas or store results as part of the dbt models. This allows Data Analysts to perform their own mathematical calculations on top of the FACT tables.

1. For each month, which agency region is Carmen Sandiego most likely to be found?

```sql
    WITH BASE AS (
    SELECT *, ROW_NUMBER() over (PARTITION BY WITNESS_MONTH ORDER BY NUM_OF_SIGHTINGS DESC) AS RANK
    FROM DEV_PRE_AGGREGATION_CS_FACT.FACT_GEOGRAPHY
    )
    SELECT *
    FROM BASE WHERE RANK = 1;
```

Result

![Screenshot from 2022-07-04 22-36-52](https://user-images.githubusercontent.com/44732615/177198001-ba5a8e7d-73fe-4e1a-a5f9-fbb8bdad2431.png)


2. For each month, what is the probability that Ms. Sandiego is armed AND wearing a jacket,
but NOT a hat? What general observations about Ms. Sandiego can you make from this?

```sql
with base as (
    select date_trunc('MONTH', date_witness) as witness_month, date_witness, attribute_match 
    from DEV_PRE_AGGREGATION_CS_FACT.FACT_ATTRIBUTE_MATCH 
    )
    select witness_month, sum(case when attribute_match = 'MATCH' THEN 1 else 0 end)/count(*) as probability_of_match from base group by 1 order by 1;
```

Result

![Screenshot from 2022-07-04 22-54-27](https://user-images.githubusercontent.com/44732615/177198106-72fa0da2-c53c-4b7c-8935-05c93427a3ba.png)

3. What are the three most occuring behaviors of Ms. Sandiego?

```sql
    select BEHAVIOR, COUNT(*)
    from DEV_PRE_AGGREGATION_CS_FACT.FACT_BEHAVIOR
    GROUP BY 1
    ORDER BY 2 DESC LIMIT 3;
```

Result

![Screenshot from 2022-07-04 22-56-42](https://user-images.githubusercontent.com/44732615/177198327-e1125350-22a4-4593-bf84-400046666a28.png)


4. For each month, what is the probability Ms. Sandiego exhibits one of her three most occurring behaviors?

```sql
     with behavior as (
    select BEHAVIOR
    from DEV_PRE_AGGREGATION_CS_FACT.FACT_BEHAVIOR
    GROUP BY 1
        order by count(*) desc limit 3
    ),
    witness_behavior as (
    select *
        from DEV_PRE_AGGREGATION_CS_FACT.FACT_BEHAVIOR
    )
    select date_trunc('MONTH', date_witness) as witness_month,
    sum(case when b.behavior is not null then 1 else 0 end)/count(wb.behavior) as prob
    from witness_behavior wb 
    left join behavior b on wb.behavior = b.behavior
    group by 1 order by 1;
```

Result

![Screenshot from 2022-07-04 22-57-35](https://user-images.githubusercontent.com/44732615/177198391-5b5f4eef-f3ce-4606-978d-b4184e62552f.png)
