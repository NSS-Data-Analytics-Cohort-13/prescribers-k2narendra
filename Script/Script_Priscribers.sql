1. 
    a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
    
    b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

select p.npi, pp.total_claim_count
from prescriber as p
inner join prescription as pp
	on p.npi = pp.npi
order by total_claim_count desc


select p.npi, p.nppes_provider_first_name, p.nppes_provider_last_org_name,  p.specialty_description, pp.total_claim_count
from prescriber as p
inner join prescription as pp
	on p.npi = pp.npi
order by total_claim_count desc


2. 
    a. Which specialty had the most total number of claims (totaled over all drugs)?

    b. Which specialty had the most total number of claims for opioids?

select p.specialty_description, sum(pp.total_claim_count) as Total_claim
from prescriber as p
inner join prescription as pp
	on p.npi = pp.npi
group by p.specialty_description
order by Total_claim desc
	
b. Which specialty had the most total number of claims for opioids? 
	
select p.specialty_description, sum(pp.total_claim_count) as Total_claim
from prescriber as p
inner join prescription as pp
	on p.npi = pp.npi
inner join drug as d
	on pp.drug_name=d.drug_name
	where d.opioid_drug_flag ='Y'
group by p.specialty_description
order by Total_claim desc

	select * from drug
c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

select p.specialty_description, sum(pp.total_claim_count) as Total_claim
from prescriber as p
left join prescription as pp
	on p.npi = pp.npi
group by p.specialty_description
order by Total_claim desc


3. 
    a. Which drug (generic_name) had the highest total drug cost?

    b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

select d.generic_name, sum(p.total_drug_cost) as Total_cost
from drug as d
inner join prescription as p
on d.drug_name=p.drug_name
group by d.generic_name
order by Total_cost desc

	
	b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**


	
select d.generic_name, sum(p.total_drug_cost) as Total_cost, sum(p.total_day_supply) as days_supply
	, round(sum(p.total_drug_cost)/sum(p.total_day_supply)) :: money as daily_cost
from drug as d
inner join prescription as p
on d.drug_name=p.drug_name
group by d.generic_name
order by daily_cost desc


	
4.
a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

    b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

	
select 
    d.drug_name,
    case when d.opioid_drug_flag = 'Y' then 'opioid'
        when d.antibiotic_drug_flag = 'Y' then 'antibiotic'
        else 'neither'
    end as drug_type
	, p.total_drug_cost
from 
    drug as d

	
	
b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
	
	
	select 
        case when d.opioid_drug_flag = 'Y' then 'opioid'
        when d.antibiotic_drug_flag = 'Y' then 'antibiotic'
        else 'neither'
    end as drug_type
	, round(sum(p.total_drug_cost)) :: Money as Total_cost
from 
    drug as d
	inner join prescription as p
on d.drug_name = p.drug_name
group by drug_type



	

5. 
    a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

select * from cbsa
select count(cbsa) from cbsa
	where cbsaname like '%TN%'


	 SELECT COUNT(*) 
FROM fips_county AS f
INNER JOIN cbsa AS c
ON f.fipscounty = c.fipscounty
WHERE f.state = 'TN'

	
--select * from cbsa

	
    b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

(select c.cbsaname, sum(p.population) as combine_population, 'largest' as flag
	from cbsa as c
	inner join population as p
	using(fipscounty)
	group by c.cbsaname
order by combine_population desc
limit 1)

	union
	
(select c.cbsaname, sum(p.population) as combine_population, 'smallest' as flag
	from cbsa as c
	inner join population as p
	using(fipscounty)
	group by c.cbsaname
order by combine_population
limit 1)
	
	

    c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.


select fi.county, p.population
from fips_county as fi
inner join population as p
	using (fipscounty)
where fipscounty not in(select fipscounty from cbsa)
order by population desc

-----alternative-----
	
SELECT f.county, SUM(p.population) as combined_population
FROM fips_county AS f
INNER JOIN population AS p 
	ON f.fipscounty = p.fipscounty
WHERE f.fipscounty IN
		--Subquery to return TN fipscounty which are not included in CBSA
		(SELECT fipscounty FROM fips_county --WHERE STATE = 'TN' --fips_county table has 96 records for TN
		EXCEPT
		SELECT fipscounty FROM cbsa) --Total 54 fipscounty are not present in CBSA
GROUP BY f.county
ORDER BY combined_population desc
LIMIT 1
	
/* Answer = "SEVIER" county with 95523 population is the largest county in terms of population, which is not included in a CBSA*/
	
6. 
    a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

	

	SELECT drug_name, total_claim_count
	FROM prescription
	WHERE total_claim_count >=3000
	ORDER BY total_claim_count
	
	

    b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

	SELECT p.drug_name, p.total_claim_count, d.opioid_drug_flag
		FROM prescription AS p
	LEFT JOIN drug AS d
	USING(drug_name)
	WHERE p.total_claim_count >= 3000
	ORDER BY p.total_claim_count

	

    c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.


SELECT pp.nppes_provider_first_name, pp.nppes_provider_last_org_name, p.drug_name, p.total_claim_count, d.opioid_drug_flag

	FROM prescription AS p
	LEFT JOIN drug AS d
	USING(drug_name)
	INNER JOIN prescriber AS pp
	USING(npi)
WHERE p.total_claim_count >= 3000
	ORDER BY p.total_claim_count

	
7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.
	


    a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


select p.npi, d.drug_name
	from prescriber as p
	cross join drug as d
	--using (npi)
	where p.specialty_description ilike 'pain management' 
		and nppes_provider_city ilike 'NASHVILLE' 
		and drug_name in (select drug_name from drug where opioid_drug_flag='Y')
---alt---


	SELECT 	p.npi
	, 	d.drug_name
FROM prescriber as p
CROSS JOIN drug as d
	WHERE 	p.specialty_description ='Pain Management' 
	AND 	p.nppes_provider_city = 'NASHVILLE' 
	AND 	d.opioid_drug_flag = 'Y'

	
    b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).


SELECT prescriber.npi
		,	drug.drug_name
		,	SUM(prescription.total_claim_count) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;

	

	
    c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

		SELECT prescriber.npi
		,	drug.drug_name
		, COALESCE(SUM(prescription.total_claim_count),0) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;

	
	
