* #1
gen trumpnum=trump/totalvotes
gen clintonnum=clinton/totalvotes
gen trump_margin=trumpnum-clintonnum

* #2
sum trump_margin white poverty population, detail

* #3
histogram trump_margin

* #4
twoway (scatter trump_margin poverty)
corr trump_margin poverty

* #5
twoway (scatter trump_margin white)
corr trump_margin white

* #6
bysort stname: egen stpopulation = sum(population)
collapse white poverty (firstnm) stpopulation [aw=population], by(stname)
list

* #7
twoway (scatter poverty white [aweight = stpopulation])
