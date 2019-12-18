import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/auth;
import ballerina/time;

auth:OutboundBasicAuthProvider outboundBasicAuthProvider = new({
    // enter GitHub credentials here
    username: "",
    password: ""
});
http:BasicAuthHandler outboundBasicAuthHandler = new(outboundBasicAuthProvider);
http:Client github = new("https://api.github.com", {
    auth: {
        authHandler: outboundBasicAuthHandler
    }
});

public function main(string... args) { 
    var response = github->get("/repos/keptn/keptn");
    if (response is http:Response) {
        json|error projectDetails = response.getJsonPayload();
        if (projectDetails is error) {
            log:printError("Failed to get /repos/keptn/keptn.", err = projectDetails);
        }
        else {
            string|error customTimeString = time:format(time:currentTime(), "w");

            // Community stats
            io:println("week, watchers, stars, forks, contributors, clones, uniqueClones, views, uniqueViews, totalDownloads,downloadsPerVersion...\n");

            map<json> project = <map<json>>projectDetails;

            io:print("CW", customTimeString, ",");
            io:print(project["subscribers_count"], ",");
            io:print(project["stargazers_count"], ",");
            io:print(project["forks_count"], ",");
            
            var contributorResponse = github->get("/repos/keptn/keptn/contributors");
            if (contributorResponse is http:Response) {
                json|error contributorList = contributorResponse.getJsonPayload();
                if (contributorList is error) {
                    log:printError("Failed to get contributors of keptn/keptn.", err = contributorList);
                }
                else {
                    json[] contributors = <json[]>contributorList;
                    io:print(contributors.length());
                    io:print(",");  
                }
            }
            var cloneResponse = github->get("/repos/keptn/keptn/traffic/clones");
            if (cloneResponse is http:Response) {
                json|error cloneList = cloneResponse.getJsonPayload();
                if (cloneList is error) {
                    log:printError("Failed to get clones of a repository.", err = cloneList);
                }
                else {
                    io:print(cloneList.count?:"?", ",", cloneList.uniques?:"?", ",");
                }
            }
            var viewResponse = github->get("/repos/keptn/keptn/traffic/views");
            if (viewResponse is http:Response) {
                json|error viewList = viewResponse.getJsonPayload();
                if (viewList is error) {
                    log:printError("Failed to get views of a repository.", err = viewList);
                }
                else {
                    io:print(viewList.count?:"?", ",", viewList.uniques?:"?", ",");
                }
            }

            // Downloads stats
            int totalDownloads = 0;
            var releaseResponse = github->get("/repos/keptn/keptn/releases");
            if (releaseResponse is http:Response) {
                json|error releaseListJson = releaseResponse.getJsonPayload();
                if (releaseListJson is error) {
                    log:printError("Failed to get releases of keptn repository.", err = releaseListJson);
                }
                else {
                    int i = 0;

                    json[] releaseList = <json[]>releaseListJson;

                    map<int> downloadsList = {};

                    while (i < releaseList.length()) {
                        map<json> release = <map<json>>releaseList[i];
                        string releaseName = <string>release["name"];
                        string firstFourOfName = releaseName.substring(0, 4);

                        string shortName = firstFourOfName + "x";

                        if (!releaseName.startsWith("0.1")) {
                            json[] assets = <json[]>release["assets"];
                            int downloads = assets.reduce(function(int total, json n) returns int {
                                map<json> asset = <map<json>>n;
                                return total + <int>asset["download_count"];
                            }, 0);

                            int previousDownloads = downloadsList[shortName] ?:0;
                            downloadsList[shortName] = previousDownloads + downloads;
                        }

                        i += 1;
                    }

                    totalDownloads = downloadsList.reduce(function(int total, int n) returns int {
                        return total + n;
                    }, 0);

                    
                    string[] keys = downloadsList.keys();
                    string[] sortedKeys = keys.sort(function(string a, string b) returns int {
                        return a.codePointCompare(b);
                    });
                    
                    io:print(totalDownloads, ",");

                    sortedKeys.forEach(function(string key) {
                        io:print(downloadsList[key], ",");
                    });
                    io:print("\n");
                }
            }
        }
    } else {
        log:printError("Failed to call the endpoint.", err = response);
    }
}
