# mql-parser - a JavaScript PEG for MetaSQL

[OpenRPT](https://github.com/xtuple/openrpt) introduced MetaSQL to simplify
writing SQL queries for reports.

People frequently clone report definitions because they need to make minor
changes to the `where` clause of the query that drives the report. For example, 
someone might need two different versions of a report, one that gives data
broken down month-to-month and another for data quarter-by-quarter. Sometimes
this can be managed by parameterizing the query but often not.

MetaSQL gives tools that allow changing the _structure_ of a query as well
as parameterizing values.

For example, here are two version of a simple parameterized query:

```SQL
select * from history where history_date >= :start; -- standard SQL style
select * from history where history_date >= <? value('start') ?>; -- MetaSQL
```

This isn't particularly interesting. Sometimes, though, the date should be optional.
Here is where MetaSQL becomes useful:

```SQL
select * from history
<? if exists('start') ?> where history_date >= <? value('start') ?><? endif ?>;
```

This will give two different queries, depending on whether a parameter named
`start` was passed.  Now we no longer need a dummy or default value for
"the beginning of time", we just pass the `start` date if we care.
