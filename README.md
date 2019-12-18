# stats

Simple tool to gather GitHub metrics.

- Install Ballerina (https://ballerina.io/downloads/)
- Provide GitHub credentials and GitHub project in `stats.bal`
- Run `ballerina run stats.bal`

Output will be somethink like this

```
week, watchers, stars, forks, contributors, clones, uniqueClones, views, uniqueViews, totalDownloads,downloadsPerVersion
CW51,18,175,23,11,169,16,3065,186,1099,232,56,292,397,122
```

Alternatively you can build an executable with `ballerina build stats.bal` and then run it with `java -jar stats.jar`.
