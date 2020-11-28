SELECT
  
  (CASE
    WHEN c4.financniZdrojKod IS NOT NULL THEN 4
    WHEN c3.financniZdrojKod IS NOT NULL THEN 3
    WHEN c2.financniZdrojKod IS NOT NULL THEN 2
    WHEN c1.financniZdrojKod IS NOT NULL THEN 1
    ELSE NULL
  END) AS financniZdrojKod_Typ,
  
  (CASE
    WHEN c4.financniZdrojKod IS NOT NULL THEN c4.financniZdrojKod
    WHEN c3.financniZdrojKod IS NOT NULL THEN c3.financniZdrojKod
    WHEN c2.financniZdrojKod IS NOT NULL THEN c2.financniZdrojKod
    WHEN c1.financniZdrojKod IS NOT NULL THEN c1.financniZdrojKod
    ELSE NULL
  END) AS financniZdrojKod_1,
  (CASE
    WHEN c4.financniZdrojKod IS NOT NULL THEN c4.financniZdrojNazev
    WHEN c3.financniZdrojKod IS NOT NULL THEN c3.financniZdrojNazev
    WHEN c2.financniZdrojKod IS NOT NULL THEN c2.financniZdrojNazev
    WHEN c1.financniZdrojKod IS NOT NULL THEN c1.financniZdrojNazev
    ELSE NULL
  END) AS financniZdrojNazev_1,

  (CASE
    WHEN c4.financniZdrojKod IS NOT NULL THEN c3.financniZdrojKod
    WHEN c3.financniZdrojKod IS NOT NULL THEN c2.financniZdrojKod
    WHEN c2.financniZdrojKod IS NOT NULL THEN c1.financniZdrojKod
    ELSE NULL
  END) AS financniZdrojKod_2,
  (CASE
    WHEN c4.financniZdrojKod IS NOT NULL THEN c3.financniZdrojNazev
    WHEN c3.financniZdrojKod IS NOT NULL THEN c2.financniZdrojNazev
    WHEN c2.financniZdrojKod IS NOT NULL THEN c1.financniZdrojNazev
    ELSE NULL
  END) AS financniZdrojNazev_2,
   
  (CASE
    WHEN c4.financniZdrojKod IS NOT NULL THEN c2.financniZdrojKod
    WHEN c3.financniZdrojKod IS NOT NULL THEN c1.financniZdrojKod
    ELSE NULL
  END) AS financniZdrojKod_3,
  (CASE
    WHEN c4.financniZdrojKod IS NOT NULL THEN c2.financniZdrojNazev
    WHEN c3.financniZdrojKod IS NOT NULL THEN c1.financniZdrojNazev
    ELSE NULL
  END) AS financniZdrojNazev_3,
  
  (CASE
    WHEN c4.financniZdrojKod IS NOT NULL THEN c1.financniZdrojKod
    ELSE NULL
  END) AS financniZdrojKod_4,
  (CASE
    WHEN c4.financniZdrojKod IS NOT NULL THEN c1.financniZdrojNazev
    ELSE NULL
  END) AS financniZdrojNazev_4,
  
  c1.*
  
FROM [diplomka-180011:cedr.ciselnikFinancniZdrojv01] AS c1

LEFT JOIN [diplomka-180011:cedr.ciselnikFinancniZdrojv01] AS c2 ON c2.financniZdrojKod = c1.financniZdrojNadrizenyKod
LEFT JOIN [diplomka-180011:cedr.ciselnikFinancniZdrojv01] AS c3 ON c3.financniZdrojKod = c2.financniZdrojNadrizenyKod
LEFT JOIN [diplomka-180011:cedr.ciselnikFinancniZdrojv01] AS c4 ON c4.financniZdrojKod = c3.financniZdrojNadrizenyKod