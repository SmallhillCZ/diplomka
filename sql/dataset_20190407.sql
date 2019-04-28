SELECT
 
 M.id AS organization_id,
 M.year,
 
 M.assets,
 M.o_assets,
 M.capital,
 M.o_result,
 M.f_result,
 M.subject_type,
 M.location,
 M.registered_capital,
 M.employees,
 M.turnover_category,
 M.nace,
 M.nace_section,
 
 COALESCE(G.amount,0) AS grants_amount,
 COALESCE(PD.amount,0) AS pd_amount
 
FROM (
  SELECT
    id,
    year,
    assets,
    o_assets,
    capital,
    o_result,
    f_result,
    subject_type,
    location,
    registered_capital,
    employees,
    turnover_category,
    nace,
    nace_section
  FROM `magnus.magnus_2014`
  WHERE
    assets IS NOT NULL
    AND capital IS NOT NULL
    AND o_result IS NOT NULL
    AND duplicate = 0
) AS M

LEFT JOIN (
    SELECT
      PRIJEMCE.ico AS organization_id,
      ROZ.rokRozhodnuti AS year,
      SUM(ROZ.castkaRozhodnuta) AS amount
    FROM cedr.PrijemcePomoci AS PRIJEMCE    
    LEFT JOIN cedr.Dotace AS DOT ON DOT.idPrijemce = PRIJEMCE.idPrijemce
    LEFT JOIN cedr.Rozhodnuti AS ROZ ON ROZ.idDotace = DOT.idDotace
    --LEFT JOIN `pomocne.source_type_lookup` AS TYPES ON TYPES.id = ROZ.iriFinancniZdroj
    GROUP BY organization_id,year
) AS G ON G.organization_id = M.id AND G.year = M.year

LEFT JOIN (
  SELECT
    year,
    organization_id,
    SUM(amount) AS amount
  FROM donations.political_donations
  WHERE amount > 0
  GROUP BY year,organization_id
) AS PD ON PD.organization_id = M.id AND PD.year = M.year