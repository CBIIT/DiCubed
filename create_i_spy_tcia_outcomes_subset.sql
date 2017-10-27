create table i_spy_tcia_outcomes_subset (
subjectid varchar(10),
dataextractdt varchar(10),
sstat int,
surv_dt_d2_tx int,
rfs int,
rfs_ind int,
pcr int,
rcb_class int);

\copy i_spy_tcia_outcomes_subset from 'i_spy_tcia_outcomes_subset_fixed.csv' delimiter ',' csv header

