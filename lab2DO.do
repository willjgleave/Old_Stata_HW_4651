///Will Gleave u1173446



import delimited "C:\Users\willj\OneDrive\Desktop\4651\lab 2\united-states.csv", encoding(UTF-8) clear 

split(endtime), p(" ")
gen date = date(endtime1, "DMY",2050)
order date
format date %td
drop endtime*

ren i2_health num_contact
label var num_contact "Number of other people contacted <6 ft" 

ren i3_health covid_test

gen postest = covid_test=="Yes, and I tested positive"
gen negtest = covid_test=="Yes, and I tested negative"
gen unktest = covid_test=="Yes, and I have not recieved my results from the test yet"
gen notest = covid_test=="No, I have not"


encode i8_health, gen(covid_travel)
encode i6_health, gen(covid_sd)



gen taken_test = inlist(covid_test,"Yes, and I tested positive","Yes, and I tested negative","Yes, and I have not recieved my results from the test yet")
gen not_taken_test = inlist(covid_test,"No, I have not")

drop covid_test

gen week = week(date)


encode i12_health_1, gen(mask)
gen yes_mask = inlist(i12_health_1,"Always","Frequently")==1
gen no_mask = inlist(i12_health_1,"Sometimes","Rarely","Not at all")


preserve
	collapse (mean) *mask *test, by (state week)
	//twoway (line yes_mask week, sort) if state=="New York"
restore

cap program drop mean_diff
program mean_diff, rclass
	args v1 v2
	quietly sum `v1' if `v2'==0, detail
	local pos_mean = r(mean)
	quietly sum `v1' if `v2'==1, detail
	local neg_mean = r(mean)
	return scalar meandiff = `pos_mean' - `neg_mean'
	display as txt "median difference = " `pos_mean' " - " `neg_mean' " = " `pos_mean' - `neg_mean'
end

mean_diff yes_mask postest

ret lis

gen diff = r(meandiff)

reg yes_mask postest
estimates store model1

reg yes_mask postest negtest num_contact
estimates store model2

estimates table _all, varlabel stats(N r2 r2_a) b(%10.3f) star

putdocx begin
putdocx table tbl1 = etable
putdocx save mydoc, replace


