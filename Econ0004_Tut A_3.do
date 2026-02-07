**************************************************
* PART A: improt data (education_spending.xls)
**************************************************
import excel "education_spending.xls", clear firstrow
* Check variable（Eg：Country, Year, Education_Spending）
describe
* Filter for USA data (based on the actual country name, e.g. "USA" or "United States")
keep if Country=="USA" | Country=="United States"
* Save the dataset
save "education_spending_USA.dta", replace

**************************************************
* PART B: import gini dataset
**************************************************
import excel "gini.xls", clear firstrow
describe
keep if Country=="USA" | Country=="United States"
* let income inequality=gini
save "gini_USA.dta", replace

**************************************************
* PART C: import (share-population-female.xls)
**************************************************
import excel "share-population-female.xls", clear firstrow
describe
* Country, Year, Female_Share
keep if Country=="USA" | Country=="United States"
save "female_share_USA.dta", replace

**************************************************
* PART D: import (tax.xls)
**************************************************
import excel "tax.xls", clear firstrow
describe
* Country, Year, Tax_Rate
keep if Country=="USA" | Country=="United States"
save "tax_USA.dta", replace

**************************************************
**************************************************
* PART E: Import Unemployment Rate Data (Unemployment_rate.xls)
**************************************************
import excel "Unemployment_rate.xls", clear firstrow
describe
* Country, Year, Unemployment_Rate
keep if Country=="USA" | Country=="United States"
save "unemployment_USA.dta", replace
* PART F: Merge all datasets
**************************************************
* Education spending data as main dataset
use "education_spending_USA.dta", clear
sort Country Year

* Merge income inequality data 
merge 1:1 Country Year using "gini_USA.dta", keep(master match) nogen

* Merge female share data
merge 1:1 Country Year using "female_share_USA.dta", keep(master match) nogen

* Merge tax data
merge 1:1 Country Year using "tax_USA.dta", keep(master match) nogen

* Merge unemployment data 
merge 1:1 Country Year using "unemployment_USA.dta", keep(master match) nogen

* Final save merge results
save "final_merged_USA.dta", replace

**************************************************
* View merged data
**************************************************
use "final_merged_USA.dta", clear
describe
summarize _all if Year >= 1991 & Year <= 2017

drop E F
* Skewness checking
foreach var of varlist _all {
    summarize `var' if Year >= 1991 & Year <= 2017, detail
}

tsset Year
*select the year 
keep if Year >= 1991 & Year <= 2017
*mutiple regression model
regress gini Female_share PPP ES Pretax MarTax UR_F UR_M, robust
avplots
*model checking：resudiual plot and qq plot
predict resid, residuals
rvfplot
qnorm resid
