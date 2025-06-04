Scrape
Scrape any page and get formatted data

The Scrape API allows you to get the data you want from web pages using with a single call. You can scrape page content and capture it's data in various formats.

For detailed usage, checkout the Scrape API Reference

Hyperbrowser exposes endpoints for starting a scrape request and for getting it's status and results. By default, scraping is handled in an asynchronous manner of first starting the job and then checking it's status until it is completed. However, with our SDKs, we provide a simple function that handles the whole flow and returns the data once the job is completed.

Installation
Node
Python
Copy
npm install @hyperbrowser/sdk
or

Copy
yarn add @hyperbrowser/sdk
Usage
Node
Python
cURL
Copy
import { Hyperbrowser } from "@hyperbrowser/sdk";
import { config } from "dotenv";

config();

const client = new Hyperbrowser({
  apiKey: process.env.HYPERBROWSER_API_KEY,
});

const main = async () => {
  // Handles both starting and waiting for scrape job response
  const scrapeResult = await client.scrape.startAndWait({
    url: "https://example.com",
  });
  console.log("Scrape result:", scrapeResult);
};

main();
Response
The Start Scrape Job POST /scrape  endpoint will return a jobId in the response which can be used to get information about the job in subsequent requests.

Copy
{
    "jobId": "962372c4-a140-400b-8c26-4ffe21d9fb9c"
}
The Get Scrape Job GET /scrape/{jobId}  will return the following data:

Copy
{
  "jobId": "962372c4-a140-400b-8c26-4ffe21d9fb9c",
  "status": "completed",
  "data": {
    "metadata": {
      "title": "Example Page",
      "description": "A sample webpage"
    },
    "markdown": "# Example Page\nThis is content...",
  }
}
The status of a scrape job can be one of pending, running, completed, failed . There can also be other optional fields like error with an error message if an error was encountered, and html and links in the data object depending on which formats are requested for the request.

To see the full schema, checkout the API Reference.

Session Configurations
You can also provide configurations for the session that will be used to execute the scrape job just as you would when creating a new session itself. These could include using a proxy or solving CAPTCHAs. To see all the different available session parameters, checkout the API Reference or Session Parameters.

Node
Python
Copy
import { Hyperbrowser } from "@hyperbrowser/sdk";
import { config } from "dotenv";

config();

const client = new Hyperbrowser({
  apiKey: process.env.HYPERBROWSER_API_KEY,
});

const main = async () => {
  const scrapeResult = await client.scrape.startAndWait({
    url: "https://example.com",
    sessionOptions: {
      useProxy: true,
      solveCaptchas: true,
      proxyCountry: "US",
      locales: ["en"],
    },
  });
  console.log("Scrape result:", scrapeResult);
};

main();
Proxy Usage and CAPTCHA solving are only available on PAID plans.

Using proxy and solving CAPTCHAs will slow down the scrape so use it if necessary.

Scrape Configurations
You can also provide optional parameters for the scrape job itself such as the formats to return, only returning the main content of the page, setting the maximum timeout for navigating to a page, etc.

Node
Python
Copy
import { Hyperbrowser } from "@hyperbrowser/sdk";
import { config } from "dotenv";

config();

const client = new Hyperbrowser({
  apiKey: process.env.HYPERBROWSER_API_KEY,
});

const main = async () => {
  const scrapeResult = await client.scrape.startAndWait({
    url: "https://example.com",
    scrapeOptions: {
      formats: ["markdown", "html", "links"],
      onlyMainContent: false,
      timeout: 15000,
    },
  });
  console.log("Scrape result:", scrapeResult);
};

main();
For a full reference on the scrape endpoint, checkout the API Reference, or read the Advanced Scraping Guide to see more advanced options for scraping.

Batch Scrape
Batch Scrape works the same as regular scrape, except instead of a single URL, you can provide a list of up to 1,000 URLs to scrape at once.

Batch Scrape is currently only available on the Ultra plan.

Node
Python
Copy
import { Hyperbrowser } from "@hyperbrowser/sdk";
import { config } from "dotenv";

config();

const client = new Hyperbrowser({
  apiKey: process.env.HYPERBROWSER_API_KEY,
});

const main = async () => {
  const scrapeResult = await client.scrape.batch.startAndWait({
    urls: ["https://example.com", "https://hyperbrowser.ai"],
    scrapeOptions: {
      formats: ["markdown", "html", "links"],
    },
  });
  console.log("Scrape result:", scrapeResult);
};

main();
Response
The Start Batch Scrape Job POST /scrape/batch  endpoint will return a jobId in the response which can be used to get information about the job in subsequent requests.

Copy
{
    "jobId": "962372c4-a140-400b-8c26-4ffe21d9fb9c"
}
The Get Batch Scrape Job GET /scrape/batch/{jobId}  will return the following data:

Copy
{
    "jobId": "962372c4-a140-400b-8c26-4ffe21d9fb9c",
    "status": "completed",
    "totalScrapedPages": 2,
    "totalPageBatches": 1,
    "currentPageBatch": 1,
    "batchSize": 20,
    "data": [
        {
            "markdown": "Hyperbrowser\n\n[Home](https://hyperbrowser.ai/)...",
            "metadata": {
                "url": "https://www.hyperbrowser.ai/",
                "title": "Hyperbrowser",
                "viewport": "width=device-width, initial-scale=1",
                "link:icon": "https://www.hyperbrowser.ai/favicon.ico",
                "sourceURL": "https://hyperbrowser.ai",
                "description": "Infinite Browsers"
            },
            "url": "hyperbrowser.ai",
            "status": "completed",
            "error": null
        },
        {
            "markdown": "Example Domain\n\n# Example Domain...",
            "metadata": {
                "url": "https://www.example.com/",
                "title": "Example Domain",
                "viewport": "width=device-width, initial-scale=1",
                "sourceURL": "https://example.com"
            },
            "url": "example.com",
            "status": "completed",
            "error": null
        }
    ]
}
The status of a batch scrape job can be one of pending, running, completed, failed . The results of all the scrapes will be an array in the data field of the response. Each scraped page will be returned in the order of the initial provided urls, and each one will have its own status and information.

To see the full schema, checkout the API Reference.

As with the single scrape, by default, batch scraping is handled in an asynchronous manner of first starting the job and then checking it's status until it is completed. However, with our SDKs, we provide a simple function (client.scrape.batch.startAndWait) that handles the whole flow and returns the data once the job is completed.

Scrape
Create new scrape job
post
https://api.hyperbrowser.ai/api/scrape

Authorizations
Body
url
string · min: 1

sessionOptions
object
Default: {"useStealth":false,"useProxy":false,"acceptCookies":false}
Hide properties
useStealth
boolean
Default: false
useProxy
boolean
Default: false
proxyServer
string
proxyServerPassword
string
proxyServerUsername
string
proxyCountry
string · enum
Possible values: ADAEAFALAMAOARATAUAWAZBABDBEBGBHBJBOBRBSBTBYBZCACFCHCICLCMCNCOCRCUCYCZDEDJDKDMECEEEGESETEUFIFJFRGBGEGHGMGRHKHNHRHTHUIDIEILINIQIRISITJMJOJPKEKHKRKWKZLBLILRLTLULVMAMCMDMEMGMKMLMMMNMRMTMUMVMXMYMZNGNLNONZOMPAPEPHPKPLPRPTPYQARANDOM_COUNTRYRORSRUSASCSDSESGSISKSNSSTDTGTHTMTNTRTTTWUAUGUSUYUZVEVGVNYEZAZMZWadaeafalamaoaratauawazbabdbebgbhbjbobrbsbtbybzcacfchciclcmcncocrcucyczdedjdkdmeceeegeseteufifjfrgbgeghgmgrhkhnhrhthuidieiliniqirisitjmjojpkekhkrkwkzlblilrltlulvmamcmdmemgmkmlmmmnmrmtmumvmxmymzngnlnonzompapephpkplprptpyqarorsrusascsdsesgsisksnsstdtgthtmtntrtttwuaugusuyuzvevgvnyezazmzw
proxyState
string · enum | nullable
Optional state code for proxies to US states. Is mutually exclusive with proxyCity. Takes in two letter state code.

Possible values: ALAKAZARCACOCTDEFLGAHIIDILINIAKSKYLAMEMDMAMIMNMSMOMTNENVNHNJNMNYNCNDOHOKORPARISCSDTNTXUTVTVAWAWVWIWYalakazarcacoctdeflgahiidiliniakskylamemdmamimnmsmomtnenvnhnjnmnyncndohokorpariscsdtntxutvtvawawvwiwy
proxyCity
string | nullable
Desired Country. Is mutually exclusive with proxyState. Some cities might not be supported, so before using a new city, we recommend trying it out

Example: new york

operatingSystems
string · enum[]

device
string · enum[]

platform
string · enum[]

locales
string · enum[]
Default: ["en"]

screen
object
solveCaptchas
boolean
Default: false
adblock
boolean
Default: false
trackers
boolean
Default: false
annoyances
boolean
Default: false
enableWebRecording
boolean
enableVideoWebRecording
boolean
enableWebRecording must also be true for this to work

Default: false

profile
object
acceptCookies
boolean
extensionIds
string · uuid[]
Default: []
urlBlocklist
string[]
Default: []
browserArgs
string[]
Default: []

imageCaptchaParams
object[] | nullable
timeoutMinutes
number · min: 1 · max: 720

scrapeOptions
object
Hide properties

formats
string · enum[]
Default: ["markdown"]
Hide properties
items
string · enum
Possible values: htmllinksmarkdownscreenshot
includeTags
string[]
excludeTags
string[]
onlyMainContent
boolean
Default: true
waitFor
number
Default: 0
timeout
number
Default: 30000
waitUntil
string · enum
Default: load
Possible values: loaddomcontentloadednetworkidle

screenshotOptions
object
Hide properties
fullPage
boolean
Default: false
format
string · enum
Default: webp
Possible values: jpegpngwebp
Responses
200
Scrape job created
application/json

Response
object
Hide properties
jobId
string
400
Invalid request parameters
application/json
500
Server error
application/json
post
/api/scrape

HTTP

HTTP
Copy
POST /api/scrape HTTP/1.1
Host: api.hyperbrowser.ai
x-api-key: YOUR_API_KEY
Content-Type: application/json
Accept: */*
Content-Length: 937

{
  "url": "text",
  "sessionOptions": {
    "useStealth": false,
    "useProxy": false,
    "proxyServer": "text",
    "proxyServerPassword": "text",
    "proxyServerUsername": "text",
    "proxyCountry": "AD",
    "proxyState": "AL",
    "proxyCity": "new york",
    "operatingSystems": [
      "windows"
    ],
    "device": [
      "desktop"
    ],
    "platform": [
      "chrome"
    ],
    "locales": [
      "aa"
    ],
    "screen": {
      "width": 1280,
      "height": 720
    },
    "solveCaptchas": false,
    "adblock": false,
    "trackers": false,
    "annoyances": false,
    "enableWebRecording": true,
    "enableVideoWebRecording": false,
    "profile": {
      "id": "text",
      "persistChanges": true
    },
    "acceptCookies": true,
    "extensionIds": [
      "123e4567-e89b-12d3-a456-426614174000"
    ],
    "urlBlocklist": [
      "text"
    ],
    "browserArgs": [
      "text"
    ],
    "imageCaptchaParams": [
      {
        "imageSelector": "text",
        "inputSelector": "text"
      }
    ],
    "timeoutMinutes": 1
  },
  "scrapeOptions": {
    "formats": [
      "html"
    ],
    "includeTags": [
      "text"
    ],
    "excludeTags": [
      "text"
    ],
    "onlyMainContent": true,
    "waitFor": 0,
    "timeout": 30000,
    "waitUntil": "load",
    "screenshotOptions": {
      "fullPage": false,
      "format": "webp"
    }
  }
}
Test it

200
Scrape job created


Copy
{
  "jobId": "text"
}
Get scrape job status
get
https://api.hyperbrowser.ai/api/scrape/{id}/status

Authorizations
Path parameters
id
string · uuid
Responses
200
Scrape job status
application/json

Response
object
Hide properties
status
string · enum
Possible values: pendingrunningcompletedfailedstopped
404
Job not found
application/json
500
Server error
application/json
get
/api/scrape/{id}/status

HTTP

HTTP
Copy
GET /api/scrape/{id}/status HTTP/1.1
Host: api.hyperbrowser.ai
x-api-key: YOUR_API_KEY
Accept: */*
Test it

200
Scrape job status


Copy
{
  "status": "pending"
}
Get scrape job status and result
get
https://api.hyperbrowser.ai/api/scrape/{id}

Authorizations
Path parameters
id
string · uuid
Responses
200
Scrape job details
application/json

Response
object
Hide properties
jobId
string
status
string · enum
Possible values: pendingrunningcompletedfailedstopped

data
object
Hide properties

metadata
object
markdown
string
html
string
links
string[]
screenshot
string
error
string
404
Job not found
application/json
500
Server error
application/json
get
/api/scrape/{id}

HTTP

HTTP
Copy
GET /api/scrape/{id} HTTP/1.1
Host: api.hyperbrowser.ai
x-api-key: YOUR_API_KEY
Accept: */*
Test it

200
Scrape job details


Copy
{
  "jobId": "text",
  "status": "pending",
  "data": {
    "metadata": {
      "ANY_ADDITIONAL_PROPERTY": "text"
    },
    "markdown": "text",
    "html": "text",
    "links": [
      "text"
    ],
    "screenshot": "text"
  },
  "error": "text"
}
Start a batch scrape job
post
https://api.hyperbrowser.ai/api/scrape/batch

Authorizations
Body
urls
string[]

sessionOptions
object
Default: {"useStealth":false,"useProxy":false,"acceptCookies":false}
Hide properties
useStealth
boolean
Default: false
useProxy
boolean
Default: false
proxyServer
string
proxyServerPassword
string
proxyServerUsername
string
proxyCountry
string · enum
Possible values: ADAEAFALAMAOARATAUAWAZBABDBEBGBHBJBOBRBSBTBYBZCACFCHCICLCMCNCOCRCUCYCZDEDJDKDMECEEEGESETEUFIFJFRGBGEGHGMGRHKHNHRHTHUIDIEILINIQIRISITJMJOJPKEKHKRKWKZLBLILRLTLULVMAMCMDMEMGMKMLMMMNMRMTMUMVMXMYMZNGNLNONZOMPAPEPHPKPLPRPTPYQARANDOM_COUNTRYRORSRUSASCSDSESGSISKSNSSTDTGTHTMTNTRTTTWUAUGUSUYUZVEVGVNYEZAZMZWadaeafalamaoaratauawazbabdbebgbhbjbobrbsbtbybzcacfchciclcmcncocrcucyczdedjdkdmeceeegeseteufifjfrgbgeghgmgrhkhnhrhthuidieiliniqirisitjmjojpkekhkrkwkzlblilrltlulvmamcmdmemgmkmlmmmnmrmtmumvmxmymzngnlnonzompapephpkplprptpyqarorsrusascsdsesgsisksnsstdtgthtmtntrtttwuaugusuyuzvevgvnyezazmzw
proxyState
string · enum | nullable
Optional state code for proxies to US states. Is mutually exclusive with proxyCity. Takes in two letter state code.

Possible values: ALAKAZARCACOCTDEFLGAHIIDILINIAKSKYLAMEMDMAMIMNMSMOMTNENVNHNJNMNYNCNDOHOKORPARISCSDTNTXUTVTVAWAWVWIWYalakazarcacoctdeflgahiidiliniakskylamemdmamimnmsmomtnenvnhnjnmnyncndohokorpariscsdtntxutvtvawawvwiwy
proxyCity
string | nullable
Desired Country. Is mutually exclusive with proxyState. Some cities might not be supported, so before using a new city, we recommend trying it out

Example: new york

operatingSystems
string · enum[]
Hide properties
items
string · enum
Possible values: windowsandroidmacoslinuxios

device
string · enum[]
Hide properties
items
string · enum
Possible values: desktopmobile

platform
string · enum[]
Hide properties
items
string · enum
Possible values: chromefirefoxsafariedge

locales
string · enum[]
Default: ["en"]
Hide properties
items
string · enum
Possible values: aaabaeafakamanarasavayazbabebgbhbibmbnbobrbscacechcocrcscucvcydadedvdzeeeleneoeseteufafffifjfofrfygagdglgngugvhahehihohrhthuhyhziaidieigiiikioisitiujajvkakgkikjkkklkmknkokrkskukvkwkylalblglilnloltlulvmgmhmimkmlmnmomrmsmtmynanbndnengnlnnnonrnvnyocojomorospapiplpsptqurmrnrorurwsascsdsesgsiskslsmsnsosqsrssstsusvswtatetgthtitktltntotrtstttwtyugukuruzvevivowawoxhyiyozazhzu

screen
object
Hide properties
width
number
Default: 1280
height
number
Default: 720
solveCaptchas
boolean
Default: false
adblock
boolean
Default: false
trackers
boolean
Default: false
annoyances
boolean
Default: false
enableWebRecording
boolean
enableVideoWebRecording
boolean
enableWebRecording must also be true for this to work

Default: false

profile
object
Hide properties
id
string
persistChanges
boolean
acceptCookies
boolean
extensionIds
string · uuid[]
Default: []
urlBlocklist
string[]
Default: []
browserArgs
string[]
Default: []

imageCaptchaParams
object[] | nullable
timeoutMinutes
number · min: 1 · max: 720

scrapeOptions
object
Hide properties

formats
string · enum[]
Default: ["markdown"]
includeTags
string[]
excludeTags
string[]
onlyMainContent
boolean
Default: true
waitFor
number
Default: 0
timeout
number
Default: 30000
waitUntil
string · enum
Default: load
Possible values: loaddomcontentloadednetworkidle

screenshotOptions
object
Hide properties
fullPage
boolean
Default: false
format
string · enum
Default: webp
Possible values: jpegpngwebp
Responses
200
Batch scrape job started successfully
application/json

Response
object
400
Invalid request parameters
application/json
402
Insufficient plan
application/json
429
Too many concurrent batch scrape jobs
application/json
500
Server error
application/json
post
/api/scrape/batch

HTTP

HTTP
Copy
POST /api/scrape/batch HTTP/1.1
Host: api.hyperbrowser.ai
x-api-key: YOUR_API_KEY
Content-Type: application/json
Accept: */*
Content-Length: 940

{
  "urls": [
    "text"
  ],
  "sessionOptions": {
    "useStealth": false,
    "useProxy": false,
    "proxyServer": "text",
    "proxyServerPassword": "text",
    "proxyServerUsername": "text",
    "proxyCountry": "AD",
    "proxyState": "AL",
    "proxyCity": "new york",
    "operatingSystems": [
      "windows"
    ],
    "device": [
      "desktop"
    ],
    "platform": [
      "chrome"
    ],
    "locales": [
      "aa"
    ],
    "screen": {
      "width": 1280,
      "height": 720
    },
    "solveCaptchas": false,
    "adblock": false,
    "trackers": false,
    "annoyances": false,
    "enableWebRecording": true,
    "enableVideoWebRecording": false,
    "profile": {
      "id": "text",
      "persistChanges": true
    },
    "acceptCookies": true,
    "extensionIds": [
      "123e4567-e89b-12d3-a456-426614174000"
    ],
    "urlBlocklist": [
      "text"
    ],
    "browserArgs": [
      "text"
    ],
    "imageCaptchaParams": [
      {
        "imageSelector": "text",
        "inputSelector": "text"
      }
    ],
    "timeoutMinutes": 1
  },
  "scrapeOptions": {
    "formats": [
      "html"
    ],
    "includeTags": [
      "text"
    ],
    "excludeTags": [
      "text"
    ],
    "onlyMainContent": true,
    "waitFor": 0,
    "timeout": 30000,
    "waitUntil": "load",
    "screenshotOptions": {
      "fullPage": false,
      "format": "webp"
    }
  }
}
Test it

200
Batch scrape job started successfully


Copy
{
  "jobId": "text"
}
Get batch scrape job status
get
https://api.hyperbrowser.ai/api/scrape/batch/{id}/status

Authorizations
Path parameters
id
string · uuid
Responses
200
Batch scrape job status
application/json

Response
object
404
Batch scrape job not found
application/json
500
Server error
application/json
get
/api/scrape/batch/{id}/status

HTTP

HTTP
Copy
GET /api/scrape/batch/{id}/status HTTP/1.1
Host: api.hyperbrowser.ai
x-api-key: YOUR_API_KEY
Accept: */*
Test it

200
Batch scrape job status


Copy
{
  "status": "pending"
}
Get batch scrape job status and results
get
https://api.hyperbrowser.ai/api/scrape/batch/{id}

Authorizations
Path parameters
id
string
Responses
200
Batch scrape job details
application/json

Response
object
400
Invalid request parameters
application/json
404
Batch scrape job not found
application/json
500
Server error
application/json
get
/api/scrape/batch/{id}

HTTP

HTTP
Copy
GET /api/scrape/batch/{id} HTTP/1.1
Host: api.hyperbrowser.ai
x-api-key: YOUR_API_KEY
Accept: */*
Test it

200
Batch scrape job details


Copy
{
  "jobId": "text",
  "status": "pending",
  "data": [
    {
      "url": "text",
      "status": "pending",
      "error": "text",
      "metadata": {
        "ANY_ADDITIONAL_PROPERTY": "text"
      },
      "markdown": "text",
      "html": "text",
      "links": [
        "text"
      ],
      "screenshot": "text"
    }
  ],
  "error": "text",