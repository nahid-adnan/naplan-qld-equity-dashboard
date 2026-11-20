# Calculated columns and tables

Definitions from the downloadable Power BI model. Each expression is shown in its own table context.

### NAPLAN_Scores · Year Level Label

```dax
Year Level Label = "Year " & MID(NAPLAN_Scores[Year Level], 3, 1)
```

### NAPLAN_Scores · Domain Label

```dax
Domain Label = SWITCH(TRUE(), NAPLAN_Scores[Domain]="READ","Reading", NAPLAN_Scores[Domain]="WRIT","Writing", NAPLAN_Scores[Domain]="SPEL","Spelling", NAPLAN_Scores[Domain]="GP","Grammar & Punctuation", NAPLAN_Scores[Domain]="NMCY","Numeracy", "N/A - Enrolment")
```

### NAPLAN_Scores · Domain Sort

```dax
Domain Sort = SWITCH(TRUE(), NAPLAN_Scores[Domain]="READ",1, NAPLAN_Scores[Domain]="WRIT",2, NAPLAN_Scores[Domain]="SPEL",3, NAPLAN_Scores[Domain]="GP",4, NAPLAN_Scores[Domain]="NMCY",5, 6)
```
