clear all
capture log close
cd "C:\Users\shale\OneDrive\Desktop\Data Analysis Project"
log using ProjectFinal.log, replace
set more off

import excel "C:\Users\shale\OneDrive\Desktop\Data Analysis Project\Data Analysis Group Project Data - SumanthiranS, HushamS, YooE.xlsx", sheet("Sheet1") firstrow

rename peace conflict
gen gdp = GDP/1000

regress LifeExpectancy PoliticalRights 
eststo first
twoway (scatter LifeExpectancy PoliticalRights) (lfit LifeExpectancy PoliticalRights),
rvfplot, yline(0)
outreg2 using first.doc, replace
asdoc estat imtest, white

regress LifeExpectancy i.System
eststo second
outreg2 using second.doc, replace
asdoc estat imtest, white

regress PoliticalRights fert gdp gini school conflict GI health 
eststo third
outreg2 using third.doc, replace
asdoc estat imtest, white

regress LifeExpectancy fert gdp gini school conflict GI health 
eststo fourth
outreg2 using fourth.doc, replace

regress LifeExpectancy PoliticalRights fert gdp gini school conflict GI health 
eststo fifth
outreg2 using fifth.doc, replace

regress LifeExpectancy i.System fert gdp gini school conflict GI health
eststo sixth
rvfplot, yline(0)
asdoc estat imtest, white
outreg2 using sixth.doc, replace

test gini school conflict health 

outreg2 [first second fifth sixth] using results.doc, adjr2 replace

asdoc pwcorr fert GDP gini school conflict GI health 

asdoc vif
