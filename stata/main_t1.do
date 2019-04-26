capture program drop psm_types

program psm_types

	foreach i in `*' {
	
		quietly {
			noisily: display "`i'"		
			drop _all

			noisily: display "loading data..."
			odbc load, exec("SELECT * FROM results.dataset_types2_20190418 WHERE year >= 2001 AND year <= 2014 AND type3 = '`i''") dsn("Diplomka BigQuery") sqlshow

			rename grants_amount outcome
			gen outcome_in = outcome > 0
			gen treatment_in = pd_amount > 0

			noisily: display "tabulating..."
			include tabulate.do
			
			noisily: display "computing..."
			noisily: include psm.do
			post psm ("`i'") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))
		}
	}

end

cls

postfile psm str4 grant_source att_outcome seatt_outcome att_outcome_in seatt_outcome_in using results_types2, replace

// list from excel statical_analyses, sheet Grants Tree
psm_types "t321" "t314" "t375"

postclose psm
