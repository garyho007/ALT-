%macro hoslem (data=, pred=, y=, ngro=10,print=T,out=hl);
/*---
Macro computes the Hosmer-Lemeshow Chi Square Statistic
for Calibration
Parameters (* = required)
-------------------------
data* input dataset
pred* Predicted Probabilities
y* Outcome 0/1 variable
ngro # of groups for the calibration test (default 10)
print Prints output (set to F to Suppress)
out output dataset (default HL)
Author: Kevin Kennedy
---*/
%let print = %upcase(&print);
proc format;
value pval 0-.0001='<.0001';
run;
data first;set &data;where &y^=. and &pred^=.;run;
proc rank groups=&ngro out=ranks data=first;ranks phat_grp;var &pred;run;
proc sort data=ranks;by phat_grp;run;
proc sql;
create table ranks2 as select *, count(*) as num_dec label='Sample Size', sum(&pred) as sum_pred
label='Sum Probabilities', sum(&y) as sum_y label='Number of Events'
from ranks
group by phat_grp;
create table ranks3 as select distinct(phat_grp),num_dec,sum_pred,sum_y,
((sum_y-sum_pred)**2/(sum_pred*(1-sum_pred/num_dec))) as chi_part label 'Chi-Square Term'
from ranks2 ;
select sum(chi_part) into :chi_sq
from ranks3;
quit;
data &out;
chi_sq=&chi_sq; label chi_sq='Hosmer Lemeshow Chi Square';
df=&ngro-2; label df ='Degree of Freedom';
p_value=1-cdf('chisquared',chi_sq,df);label p_value= 'P-Value';
format p_value pval.;
run;
%if &print=T %then %do;
title 'Hosmer Lemeshow Details';
proc print data=ranks3 noobs label;run;
Options formdlim='-';
title 'Hosmer Lemeshow Calibration Test';
proc print data=&out noobs label;run;
%end;
Options formdlim='';
%mend;