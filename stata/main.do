capture program drop grants_psm

program grants_psm

	drop _all
	cls

	cd "C:\Users\micro\Google Drive\IES\Diplomka\Stata"

	postfile psm str20 grant_type str20 donation_time att_outcome seatt_outcome att_outcome_in seatt_outcome_in using results, replace

	quietly {
		// ALL GRANTS
		noisily: display "ALL GRANTS"
		drop _all

		noisily: display "loading data..."
		odbc load, exec("SELECT * FROM results.dataset_20190407 WHERE year >= 2001 AND year <= 2014") dsn("Diplomka BigQuery") sqlshow

		rename grants_amount outcome
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("ALL GRANTS") ("SAME YEAR") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))

		// EU Funds
		noisily: display "EU FUNDS"
		drop _all

		noisily: display "loading data..."
		odbc load, exec("SELECT * FROM results.dataset_types_20190407 WHERE type='z2' AND year >= 2001 AND year <= 2014") dsn("Diplomka BigQuery") sqlshow

		rename grants_amount outcome
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("EU FUNDS") ("SAME YEAR") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))

		// State Budget 
		noisily: display "STATE BUDGET"
		drop _all

		noisily: display "loading data..."
		odbc load, exec("SELECT * FROM results.dataset_types_20190407 WHERE type='t1' AND year >= 2001 AND year <= 2014") dsn("Diplomka BigQuery") sqlshow

		rename grants_amount outcome
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("STATE BUDGET") ("SAME YEAR") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))

		// State Funds 
		noisily: display "STATE FUNDS"
		drop _all

		noisily: display "loading data..."
		odbc load, exec("SELECT * FROM results.dataset_types_20190407 WHERE type='t2' AND year >= 2001 AND year <= 2014") dsn("Diplomka BigQuery") sqlshow

		rename grants_amount outcome
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("STATE FUNDS") ("SAME YEAR") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))

	/* LAGGED THREE YEARS BACK */
		// ALL GRANTS
		noisily: display "ALL GRANTS 3Y BACK"
		drop _all

		noisily: display "loading data..."
		#delimit ;
		odbc load, exec("
			SELECT
			  NOW.*,
			  (COALESCE(Y1.pd_amount,0) + COALESCE(Y2.pd_amount,0) + COALESCE(Y3.pd_amount,0)) AS pd_amount_3y
			FROM results.dataset_20190407 AS NOW
			LEFT JOIN results.dataset_20190407 AS Y1 ON Y1.organization_id = NOW.organization_id AND Y1.year = NOW.year - 1
			LEFT JOIN results.dataset_20190407 AS Y2 ON Y2.organization_id = NOW.organization_id AND Y2.year = NOW.year - 2
			LEFT JOIN results.dataset_20190407 AS Y3 ON Y3.organization_id = NOW.organization_id AND Y3.year = NOW.year - 3
			WHERE NOW.year >= 2004 AND NOW.year <= 2014
		") dsn("Diplomka BigQuery") sqlshow;
		#delimit cr;

		gen outcome = grants_amount
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount_3y > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("ALL GRANTS") ("3Y BACK") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))
		
		// EU FUNDS
		noisily: display "EU FUNDS 3Y BACK"
		drop _all

		noisily: display "loading data..."
		#delimit ;
		odbc load, exec("
			SELECT
			  NOW.*,
			  (COALESCE(Y1.pd_amount,0) + COALESCE(Y2.pd_amount,0) + COALESCE(Y3.pd_amount,0)) AS pd_amount_3y
			FROM results.dataset_types_20190407 AS NOW
			LEFT JOIN results.dataset_types_20190407 AS Y1 ON Y1.organization_id = NOW.organization_id AND NOW.type = Y1.type AND Y1.year = NOW.year - 1
			LEFT JOIN results.dataset_types_20190407 AS Y2 ON Y2.organization_id = NOW.organization_id AND NOW.type = Y2.type AND Y2.year = NOW.year - 2
			LEFT JOIN results.dataset_types_20190407 AS Y3 ON Y3.organization_id = NOW.organization_id AND NOW.type = Y3.type AND Y3.year = NOW.year - 3
			WHERE NOW.type = 'z2' AND NOW.year >= 2004 AND NOW.year <= 2014
		") dsn("Diplomka BigQuery") sqlshow;
		#delimit cr;

		gen outcome = grants_amount
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount_3y > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("EU FUNDS") ("3Y BACK") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))
		
		// STATE BUDGET
		noisily: display "STATE BUDGET 3Y BACK"
		drop _all

		noisily: display "loading data..."
		#delimit ;
		odbc load, exec("
			SELECT
			  NOW.*,
			  (COALESCE(Y1.pd_amount,0) + COALESCE(Y2.pd_amount,0) + COALESCE(Y3.pd_amount,0)) AS pd_amount_3y
			FROM results.dataset_types_20190407 AS NOW
			LEFT JOIN results.dataset_types_20190407 AS Y1 ON Y1.organization_id = NOW.organization_id AND NOW.type = Y1.type AND Y1.year = NOW.year - 1
			LEFT JOIN results.dataset_types_20190407 AS Y2 ON Y2.organization_id = NOW.organization_id AND NOW.type = Y2.type AND Y2.year = NOW.year - 2
			LEFT JOIN results.dataset_types_20190407 AS Y3 ON Y3.organization_id = NOW.organization_id AND NOW.type = Y3.type AND Y3.year = NOW.year - 3
			WHERE NOW.type = 't1' AND NOW.year >= 2004 AND NOW.year <= 2014
		") dsn("Diplomka BigQuery") sqlshow;
		#delimit cr;

		gen outcome = grants_amount
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount_3y > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("STATE BUDGET") ("3Y BACK") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))
		
		// STATE FUNDS
		noisily: display "STATE FUNDS 3Y BACK"
		drop _all

		noisily: display "loading data..."
		#delimit ;
		odbc load, exec("
			SELECT
			  NOW.*,
			  (COALESCE(Y1.pd_amount,0) + COALESCE(Y2.pd_amount,0) + COALESCE(Y3.pd_amount,0)) AS pd_amount_3y
			FROM results.dataset_types_20190407 AS NOW
			LEFT JOIN results.dataset_types_20190407 AS Y1 ON Y1.organization_id = NOW.organization_id AND NOW.type = Y1.type AND Y1.year = NOW.year - 1
			LEFT JOIN results.dataset_types_20190407 AS Y2 ON Y2.organization_id = NOW.organization_id AND NOW.type = Y2.type AND Y2.year = NOW.year - 2
			LEFT JOIN results.dataset_types_20190407 AS Y3 ON Y3.organization_id = NOW.organization_id AND NOW.type = Y3.type AND Y3.year = NOW.year - 3
			WHERE NOW.type = 't2' AND NOW.year >= 2004 AND NOW.year <= 2014
		") dsn("Diplomka BigQuery") sqlshow;
		#delimit cr;

		gen outcome = grants_amount
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount_3y > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("STATE FUNDS") ("3Y BACK") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))
		

	/* LAGGED THREE YEARS FORWARD */
		// ALL GRANTS
		noisily: display "ALL GRANTS 3Y FWD"
		drop _all

		noisily: display "loading data..."
		#delimit ;
		odbc load, exec("
			SELECT
			  NOW.*,
			  (COALESCE(Y1.pd_amount,0) + COALESCE(Y2.pd_amount,0) + COALESCE(Y3.pd_amount,0)) AS pd_amount_3y
			FROM results.dataset_20190407 AS NOW
			LEFT JOIN results.dataset_20190407 AS Y1 ON Y1.organization_id = NOW.organization_id AND Y1.year = NOW.year + 1
			LEFT JOIN results.dataset_20190407 AS Y2 ON Y2.organization_id = NOW.organization_id AND Y2.year = NOW.year + 2
			LEFT JOIN results.dataset_20190407 AS Y3 ON Y3.organization_id = NOW.organization_id AND Y3.year = NOW.year + 3
			WHERE NOW.year >= 2001 AND NOW.year <= 2011
		") dsn("Diplomka BigQuery") sqlshow;
		#delimit cr;

		gen outcome = grants_amount
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount_3y > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("ALL GRANTS") ("3Y FWD") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))
		
		// EU FUNDS
		noisily: display "EU FUNDS 3Y FWD"
		drop _all

		noisily: display "loading data..."
		#delimit ;
		odbc load, exec("
			SELECT
			  NOW.*,
			  (COALESCE(Y1.pd_amount,0) + COALESCE(Y2.pd_amount,0) + COALESCE(Y3.pd_amount,0)) AS pd_amount_3y
			FROM results.dataset_types_20190407 AS NOW
			LEFT JOIN results.dataset_types_20190407 AS Y1 ON Y1.organization_id = NOW.organization_id AND NOW.type = Y1.type AND Y1.year = NOW.year + 1
			LEFT JOIN results.dataset_types_20190407 AS Y2 ON Y2.organization_id = NOW.organization_id AND NOW.type = Y2.type AND Y2.year = NOW.year + 2
			LEFT JOIN results.dataset_types_20190407 AS Y3 ON Y3.organization_id = NOW.organization_id AND NOW.type = Y3.type AND Y3.year = NOW.year + 3
			WHERE NOW.type = 'z2' AND NOW.year >= 2001 AND NOW.year <= 2011
		") dsn("Diplomka BigQuery") sqlshow;
		#delimit cr;

		gen outcome = grants_amount
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount_3y > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("EU FUNDS") ("3Y FWD") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))
		
		// STATE BUDGET
		noisily: display "STATE BUDGET 3Y FWD"
		drop _all

		noisily: display "loading data..."
		#delimit ;
		odbc load, exec("
			SELECT
			  NOW.*,
			  (COALESCE(Y1.pd_amount,0) + COALESCE(Y2.pd_amount,0) + COALESCE(Y3.pd_amount,0)) AS pd_amount_3y
			FROM results.dataset_types_20190407 AS NOW
			LEFT JOIN results.dataset_types_20190407 AS Y1 ON Y1.organization_id = NOW.organization_id AND NOW.type = Y1.type AND Y1.year = NOW.year + 1
			LEFT JOIN results.dataset_types_20190407 AS Y2 ON Y2.organization_id = NOW.organization_id AND NOW.type = Y2.type AND Y2.year = NOW.year + 2
			LEFT JOIN results.dataset_types_20190407 AS Y3 ON Y3.organization_id = NOW.organization_id AND NOW.type = Y3.type AND Y3.year = NOW.year + 3
			WHERE NOW.type = 't1' AND NOW.year >= 2001 AND NOW.year <= 2011
		") dsn("Diplomka BigQuery") sqlshow;
		#delimit cr;

		gen outcome = grants_amount
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount_3y > 0

		noisily: display "tabulating..."
		include tabulate.do
		
		noisily: display "computing..."
		noisily: include psm.do
		post psm ("STATE BUDGET") ("3Y FWD") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))
		
		// STATE FUNDS
		noisily: display "STATE FUNDS 3Y FWD"
		drop _all

		noisily: display "loading data..."
		#delimit ;
		odbc load, exec("
			SELECT
			  NOW.*,
			  (COALESCE(Y1.pd_amount,0) + COALESCE(Y2.pd_amount,0) + COALESCE(Y3.pd_amount,0)) AS pd_amount_3y
			FROM results.dataset_types_20190407 AS NOW
			LEFT JOIN results.dataset_types_20190407 AS Y1 ON Y1.organization_id = NOW.organization_id AND NOW.type = Y1.type AND Y1.year = NOW.year + 1
			LEFT JOIN results.dataset_types_20190407 AS Y2 ON Y2.organization_id = NOW.organization_id AND NOW.type = Y2.type AND Y2.year = NOW.year + 2
			LEFT JOIN results.dataset_types_20190407 AS Y3 ON Y3.organization_id = NOW.organization_id AND NOW.type = Y3.type AND Y3.year = NOW.year + 3
			WHERE NOW.type = 't2' AND NOW.year >= 2001 AND NOW.year <= 2011
		") dsn("Diplomka BigQuery") sqlshow;
		#delimit cr;

		gen outcome = grants_amount
		gen outcome_in = outcome > 0
		gen treatment_in = pd_amount_3y > 0

		noisily: display "tabulating..."
		include tabulate.do

		noisily: display "computing..."
		noisily: include psm.do
		post psm ("STATE FUNDS") ("3Y FWD") (r(att_outcome)) (r(seatt_outcome)) (r(att_outcome_in)) (r(seatt_outcome_in))
	}

	postclose psm

end

grants_psm
