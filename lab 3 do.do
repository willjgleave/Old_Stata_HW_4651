Will Gleave U 1173446



cd "C:\Users\willj\OneDrive\Desktop\4651\lab 3"


ssc install shp2dta
ssc install vincenty

import delimited "C:\Users\willj\OneDrive\Desktop\4651\lab 3\SNAP_Store_Locations.csv", encoding(UTF-8) clear
keep if state== "NY"
keep if inlist(county, "NEW YORK", "KINGS", "QUEENS", "BRONX")==1
replace store_name = lower(store_name)
keep if regexm(store_name, "target")
keep x y 
save ny_target, replace 

//Airbnb data
import delimited "C:\Users\willj\OneDrive\Desktop\4651\lab 3\archive\AB_NYC_2019.csv", clear 
drop if missing(availability_365)==1 
destring id,replace
recode price (0/100=1) (101/500=2) (501/.=3), gen(pricerecode)
bys pricerecode: sum price

//regexp
replace name = lower(name)
gen cozy = regexm(name,"cozy")==1
list name if cozy==1
gen cozy2 = regexs(1) if regexm(name,"cozy(.*)$")

gen hip = regexm(name, "hip")==1

gen space = regexs(1) if regexm(name," ([a-z]*spac[a-z]*)")
tab space
gen central_park = regexm(name,"central park")==1
list name if central_park==1

//splitting
split name,p(,)
drop name?

compress
tempfile temp_aribnb
save `temp_aribnb'

use id lat lon using `temp_aribnb'
cross using ny_target

vincenty lat lon y x, v(d)	
gcollapse (min) d_target = d, by(id)
tempfile d_target 
save `d_target'

use `temp_aribnb' , clear

merge 1:1 id using `d_target' , nogen keep (1 3) 

sum d_target, d
recode d_target (0/0.5 = 1) (0.51/5=2) (5.01/.=3), gen(d_target_recode)

save airbnb_nyc,replace
