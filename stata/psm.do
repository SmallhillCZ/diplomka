psmatch2 treatment_in assets capital f_result nace_section_in* turnover_category_in* location_in* year_in* employees, out(outcome outcome_in) common ai(1) quietly

//psgraph

//pstest assets nace_section_in* turnover_category_in* location_in* employees
