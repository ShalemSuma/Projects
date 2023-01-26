******************************************************************************************************
* we start off with basic housekeeping
clear all
capture close
cd /Users/kristinasisiakova/Documents/Stata/Project
log using Project.log, append
set more off

******************************************************************************************************
* we import the excel file

import excel /Users/kristinasisiakova/Documents/Stata/Project/Data_Extract_From_World_Development_Indicators.xlsx, sheet("Data") firstrow


******************************************************************************************************
* we rename the variables

rename CountryName country
rename Adjustednetnationalincomeper income
rename Laborforceparticipationrate participation
rename Educationalattainmentatleast education
rename Fertilityratetotalbirthspe fertility
rename PopulationtotalSPPOPTOTL population

label variable income "Net national income per capita"
label variable participation "Rate of female participation in labor force"
label variable education "Educational attainment at least completed lower secondary "
label variable fertility "Fertility rate"
label variable population "Total population"

summarize

******************************************************************************************************

sum income, detail
generate income_z = (income - r(mean))/r(sd)
histogram income_z, frequency,
graph export "Graph_income(x)_zscores_frequency.png", replace


sum participation, detail
generate participation_z = (participation - r(mean))/r(sd)
histogram participation_z, frequency 
graph export "Graph_participation(y)_zscores_frequency.png", replace

******************************************************************************************************
* LET'S STUDY THE RELATIONSHIP BETWEEN INCOME AS OUR X-VARIABLE AND PARTICIPATION AS OUR Y-VARIABLE
******************************************************************************************************

******************************************************************************************************
* to see the relationship between income (X) and participation (Y) we draw a 
* scatter plot with regression line
#delimit ;
twoway (scatter participation income) (lfit participation income),
title("Effects of GDP Per Capita on the Labor Force Particiaption")
ytitle("Labor Force Participation")
xtitle("GDP Per Capita")
graphregion(fcolor(white));
#delimit cr
graph export "Graph_participation(y)_income(x).png", replace
* we try the log transformation
gen l_income = ln(income)
#delimit ;
twoway (scatter participation l_income) (lfit participation l_income),
title("Effects of GDP Per Capita on the Labor Force Particiaption")
ytitle("Labor Force Participation")
xtitle("LOG of GDP Per Capita")
graphregion(fcolor(white));
#delimit cr
graph export "Graph_participation(y)_income(x)_LOG.png", replace

******************************************************************************************************
* predicted values and residuals
corr participation income
regress participation income
eststo income
outreg2 [income] using Regression_income.doc, dec(6) replace

predict pred_participation
predict res_participation, residuals
list participation pred_participation res_participation 

* from the predicted values we can see that the current model is not sufficient

******************************************************************************************************
* to check the "zero conditional mean of errors"
summarize res_participation
#delimit ;
twoway lowess res_participation income,
title("Plot of Residuals with Lowess Line")
ytitle("Residuals")
xtitle("GDP Per Capita")
graphregion(fcolor(white));
#delimit cr
graph export "Graph_participation(y)_income(x)_residuals_lowess.png", replace

* residuals vs fitted plot
#delimit ;
rvfplot, yline (0)
title("Fitted Plot of Residuals")
ytitle("Residuals")
xtitle("GDP Per Capita")
graphregion(fcolor(white));
#delimit cr
graph export "Graph_participation(y)_income(x)_residuals_fitted.png", replace

* from the graph we see that the assumption that our error term is 0 is violated
* we suspect ommited variable bias

******************************************************************************************************
* homoscedasticity
regress participation income
estat imtest, white

* p is too low, so we reject the null hypothesis, and have the evidence for 
* heteroskedasticity - the error term is not constant (also from the graph,the fitted values increase, the heteroskedasticity increases too)
* this is a limitation of the model
* the null is that participation is effected by GDP, but we find that it 
* is effected by many factors


******************************************************************************************************
******************************************************************************************************



*** OMMITED VARIABLE BIAS ***
* we add more variables to prevent the ommited variable bias


*** EDUCATION
* we have participation (Y), income (X) and education (W)

* 1) to see the relationship between education (W) and participation (Y) 
* we draw a scatter plot with regression line
#delimit ;
twoway (scatter participation education) (lfit participation education),
title("Effects of Education on the Labor Force Particiaption")
ytitle("Labor Force Participation")
xtitle("Education")
graphregion(fcolor(white));
#delimit cr
graph export "Graph_participation(y)_education(w).png", replace
* we plot the residuals
regress participation education
#delimit ;
rvfplot, yline (0)
title("Fitted Plot of Residuals")
ytitle("Residuals")
xtitle("Education")
graphregion(fcolor(white));
#delimit cr
graph export "Graph_participation(y)_education(w)_residuals_fitted.png", replace
* we try the log transformation
gen l_education = ln(education)
#delimit ;
twoway (scatter participation l_education) (lfit participation l_education),
title("Effects of Education on the Labor Force Particiaption")
ytitle("Labor Force Participation")
xtitle("LOG of Education")
graphregion(fcolor(white));
#delimit cr
graph export "Graph_participation(y)_education(w)_LOG.png", replace

corr participation education
regress participation education
eststo education
outreg2 [education] using Regression_education_participation.doc, dec(3) replace

* homoscedasticity
regress participation education
estat imtest, white

* p value low, we reject the null 
* labor force pariticipation is influenced by educational attainment 
******************************************************************************************************

******************************************************************************************************
corr participation income education
regress participation income education
outreg2 [income education] using Regression_education.doc, dec(6) replace

* since the adjusted r-squared is higher than the original one, it seems like 
* educational attainment is a valid factor
******************************************************************************************************

*** FERTILITY
* we have participation (Y), income (X) and fertility (V)

* 1) to see the relationship between fertility (V) and participation (Y) 
* we draw a scatter plot with regression line
#delimit ;
twoway (scatter participation fertility) (lfit participation fertility),
title("Effects of Fertility on the Labor Force Particiaption")
ytitle("Labor Force Participation")
xtitle("Fertility")
graphregion(fcolor(white));
#delimit cr
graph export "Graph_participation(y)_fertility(v).png", replace
* we plot the residuals
regress participation fertility
#delimit ;
rvfplot, yline (0)
title("Fitted Plot of Residuals")
ytitle("Residuals")
xtitle("Fertility")
graphregion(fcolor(white));
#delimit cr
graph export "Graph_participation(y)_fertility(v)_residuals_fitted.png", replace
* we try the log transformation
gen l_fertility = ln(fertility)
#delimit ;
twoway (scatter participation l_fertility) (lfit participation l_fertility),
title("Effects of Fertility on the Labor Force Particiaption")
ytitle("Labor Force Participation")
xtitle("LOG of Fertility")
graphregion(fcolor(white));
#delimit cr
graph export "Graph_participation(y)_fertility(v)_LOG.png", replace

corr participation fertility
regress participation fertility
eststo fertility
outreg2 [fertility] using Regression_fertility_participation.doc, dec(3) replace

* homoscedasticity
regress participation fertility
estat imtest, white

* p value low, we can reject the null 
* the participation is influenced by fertility 
******************************************************************************************************

******************************************************************************************************
corr participation income fertility
regress participation income fertility
outreg2 [income fertility] using Regression_fertility.doc, dec(6) replace


* adjusted r-squared is lower than the original one, therefore fertility seems 
* like an invalid factor
******************************************************************************************************
corr participation income education fertility
regress participation income education fertility
eststo xwv

outreg2 [income education fertility xwv] using Regressions.doc, dec(6) replace

* we don't use this model as fertility is invalid factor 
* in the final model we use income and education only - this way the model is 
* statistically significant and has a higher adjusted r-squared

corr participation income education
regress participation income education
eststo incomeeducation

outreg2 [incomeeducation] using Regressions_income_education.doc, dec(6) replace

log close






