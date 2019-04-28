SELECT
 
 M.id AS organization_id,
 M.year,
 T.type2,
 T.type3,
 
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

CROSS JOIN (
  SELECT
    financniZdrojKod_2 AS type2,
    financniZdrojKod_3 AS type3
  FROM `pomocne.source_type_lookup` 
  WHERE financniZdrojKod_Typ = 3 AND financniZdrojKod_2 IN ('t1','t2','t7','z2')
) AS T

LEFT JOIN (
    SELECT
      PRIJEMCE.ico AS organization_id,
      ROZ.rokRozhodnuti AS year,      
      T.financniZdrojKod_3 AS type3,
      SUM(ROZ.castkaRozhodnuta) AS amount
    FROM cedr.PrijemcePomoci AS PRIJEMCE    
    LEFT JOIN cedr.Dotace AS DOT ON DOT.idPrijemce = PRIJEMCE.idPrijemce
    LEFT JOIN cedr.Rozhodnuti AS ROZ ON ROZ.idDotace = DOT.idDotace
    LEFT JOIN `pomocne.source_type_lookup` AS T ON T.id = ROZ.iriFinancniZdroj
    GROUP BY organization_id,year,type3
) AS G ON G.organization_id = M.id AND G.year = M.year AND G.type3 = t.type3

LEFT JOIN (
  SELECT
    year,
    organization_id,
    SUM(amount) AS amount
  FROM donations.political_donations
  WHERE amount > 0
  GROUP BY year,organization_id
) AS PD ON PD.organization_id = M.id AND PD.year = M.year