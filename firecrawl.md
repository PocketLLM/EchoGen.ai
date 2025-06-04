# Scrape

> Turn any url into clean data

Firecrawl converts web pages into markdown, ideal for LLM applications.

* It manages complexities: proxies, caching, rate limits, js-blocked content
* Handles dynamic content: dynamic websites, js-rendered sites, PDFs, images
* Outputs clean markdown, structured data, screenshots or html.

For details, see the [Scrape Endpoint API Reference](https://docs.firecrawl.dev/api-reference/endpoint/scrape).

## Scraping a URL with Firecrawl

### /scrape endpoint

Used to scrape a URL and get its content.

### Installation

<CodeGroup>
  ```bash Python
  pip install firecrawl-py
  ```

  ```bash Node
  npm install @mendable/firecrawl-js
  ```

  ```bash Go
  go get github.com/mendableai/firecrawl-go
  ```

  ```yaml Rust
  # Add this to your Cargo.toml
  [dependencies]
  firecrawl = "^1.0"
  tokio = { version = "^1", features = ["full"] }
  ```
</CodeGroup>

### Usage

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape a website:
  scrape_result = app.scrape_url('firecrawl.dev', formats=['markdown', 'html'])
  print(scrape_result)
  ```

  ```js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape a website:
  const scrapeResult = await app.scrapeUrl('firecrawl.dev', { formats: ['markdown', 'html'] }) as ScrapeResponse;

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult)
  ```

  ```go Go
  import (
  	"fmt"
  	"log"

  	"github.com/mendableai/firecrawl-go"
  )

  func main() {
  	// Initialize the FirecrawlApp with your API key
  	apiKey := "fc-YOUR_API_KEY"
  	apiUrl := "https://api.firecrawl.dev"
  	version := "v1"

  	app, err := firecrawl.NewFirecrawlApp(apiKey, apiUrl, version)
  	if err != nil {
  		log.Fatalf("Failed to initialize FirecrawlApp: %v", err)
  	}

  	// Scrape a website
  	scrapeResult, err := app.ScrapeUrl("https://firecrawl.dev", map[string]any{
  		"formats": []string{"markdown", "html"},
  	})
  	if err != nil {
  		log.Fatalf("Failed to scrape URL: %v", err)
  	}

  	fmt.Println(scrapeResult)
  }
  ```

  ```rust Rust
  use firecrawl::{FirecrawlApp, scrape::{ScrapeOptions, ScrapeFormats}};

  #[tokio::main]
  async fn main() {
      // Initialize the FirecrawlApp with the API key
      let app = FirecrawlApp::new("fc-YOUR_API_KEY").expect("Failed to initialize FirecrawlApp");

      let options = ScrapeOptions {
          formats vec! [ ScrapeFormats::Markdown, ScrapeFormats::HTML ].into(),
          ..Default::default()
      };

      let scrape_result = app.scrape_url("https://firecrawl.dev", options).await;

      match scrape_result {
          Ok(data) => println!("Scrape Result:\n{}", data.markdown.unwrap()),
          Err(e) => eprintln!("Map failed: {}", e),
      }
  }
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "url": "https://docs.firecrawl.dev",
        "formats" : ["markdown", "html"]
      }'
  ```
</CodeGroup>

For more details about the parameters, refer to the [API Reference](https://docs.firecrawl.dev/api-reference/endpoint/scrape).

### Response

SDKs will return the data object directly. cURL will return the payload exactly as shown below.

```json
{
  "success": true,
  "data" : {
    "markdown": "Launch Week I is here! [See our Day 2 Release 🚀](https://www.firecrawl.dev/blog/launch-week-i-day-2-doubled-rate-limits)[💥 Get 2 months free...",
    "html": "<!DOCTYPE html><html lang=\"en\" class=\"light\" style=\"color-scheme: light;\"><body class=\"__variable_36bd41 __variable_d7dc5d font-inter ...",
    "metadata": {
      "title": "Home - Firecrawl",
      "description": "Firecrawl crawls and converts any website into clean markdown.",
      "language": "en",
      "keywords": "Firecrawl,Markdown,Data,Mendable,Langchain",
      "robots": "follow, index",
      "ogTitle": "Firecrawl",
      "ogDescription": "Turn any website into LLM-ready data.",
      "ogUrl": "https://www.firecrawl.dev/",
      "ogImage": "https://www.firecrawl.dev/og.png?123",
      "ogLocaleAlternate": [],
      "ogSiteName": "Firecrawl",
      "sourceURL": "https://firecrawl.dev",
      "statusCode": 200
    }
  }
}
```

## Scrape Formats

You can now choose what formats you want your output in. You can specify multiple output formats. Supported formats are:

* Markdown (markdown)
* HTML (html)
* Raw HTML (rawHtml) (with no modifications)
* Screenshot (screenshot or screenshot\@fullPage)
* Links (links)
* JSON (json) - structured output

Output keys will match the format you choose.

## Extract structured data

### /scrape (with json) endpoint

Used to extract structured data from scraped pages.

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp, JsonConfig
  from pydantic import BaseModel, Field

  # Initialize the FirecrawlApp with your API key
  app = FirecrawlApp(api_key='your_api_key')

  class ExtractSchema(BaseModel):
      company_mission: str
      supports_sso: bool
      is_open_source: bool
      is_in_yc: bool

  json_config = JsonConfig(
      extractionSchema=ExtractSchema.model_json_schema(),
      mode="llm-extraction",
      pageOptions={"onlyMainContent": True}
  )

  llm_extraction_result = app.scrape_url(
      'https://firecrawl.dev',
      formats=["json"],
      json_options=json_config
  )
  print(llm_extraction_result)
  ```

  ```js Node
  import FirecrawlApp from "@mendable/firecrawl-js";
  import { z } from "zod";

  const app = new FirecrawlApp({
    apiKey: "fc-YOUR_API_KEY"
  });

  // Define schema to extract contents into
  const schema = z.object({
    company_mission: z.string(),
    supports_sso: z.boolean(),
    is_open_source: z.boolean(),
    is_in_yc: z.boolean()
  });

  const scrapeResult = await app.scrapeUrl("https://docs.firecrawl.dev/", {
    formats: ["json"],
    jsonOptions: { schema: schema }
  });

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult.json);
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "url": "https://docs.firecrawl.dev/",
        "formats": ["json"],
        "jsonOptions": {
          "schema": {
            "type": "object",
            "properties": {
              "company_mission": {
                        "type": "string"
              },
              "supports_sso": {
                        "type": "boolean"
              },
              "is_open_source": {
                        "type": "boolean"
              },
              "is_in_yc": {
                        "type": "boolean"
              }
            },
            "required": [
              "company_mission",
              "supports_sso",
              "is_open_source",
              "is_in_yc"
            ]
          }
        }
      }'
  ```
</CodeGroup>

Output:

```json JSON
{
    "success": true,
    "data": {
      "json": {
        "company_mission": "AI-powered web scraping and data extraction",
        "supports_sso": true,
        "is_open_source": true,
        "is_in_yc": true
      },
      "metadata": {
        "title": "Firecrawl",
        "description": "AI-powered web scraping and data extraction",
        "robots": "follow, index",
        "ogTitle": "Firecrawl",
        "ogDescription": "AI-powered web scraping and data extraction",
        "ogUrl": "https://firecrawl.dev/",
        "ogImage": "https://firecrawl.dev/og.png",
        "ogLocaleAlternate": [],
        "ogSiteName": "Firecrawl",
        "sourceURL": "https://firecrawl.dev/"
      },
    }
}
```

### Extracting without schema (New)

You can now extract without a schema by just passing a `prompt` to the endpoint. The llm chooses the structure of the data.

<CodeGroup>
  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "url": "https://docs.firecrawl.dev/",
        "formats": ["json"],
        "jsonOptions": {
          "prompt": "Extract the company mission from the page."
        }
      }'
  ```
</CodeGroup>

Output:

```json JSON
{
    "success": true,
    "data": {
      "json": {
        "company_mission": "AI-powered web scraping and data extraction",
      },
      "metadata": {
        "title": "Firecrawl",
        "description": "AI-powered web scraping and data extraction",
        "robots": "follow, index",
        "ogTitle": "Firecrawl",
        "ogDescription": "AI-powered web scraping and data extraction",
        "ogUrl": "https://firecrawl.dev/",
        "ogImage": "https://firecrawl.dev/og.png",
        "ogLocaleAlternate": [],
        "ogSiteName": "Firecrawl",
        "sourceURL": "https://firecrawl.dev/"
      },
    }
}
```

### JSON options object

The `jsonOptions` object accepts the following parameters:

* `schema`: The schema to use for the extraction.
* `systemPrompt`: The system prompt to use for the extraction.
* `prompt`: The prompt to use for the extraction without a schema.

## Interacting with the page with Actions

Firecrawl allows you to perform various actions on a web page before scraping its content. This is particularly useful for interacting with dynamic content, navigating through pages, or accessing content that requires user interaction.

Here is an example of how to use actions to navigate to google.com, search for Firecrawl, click on the first result, and take a screenshot.

It is important to almost always use the `wait` action before/after executing other actions to give enough time for the page to load.

### Example

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape a website:
  scrape_result = app.scrape_url('firecrawl.dev', 
      formats=['markdown', 'html'], 
      actions=[
          {"type": "wait", "milliseconds": 2000},
          {"type": "click", "selector": "textarea[title=\"Search\"]"},
          {"type": "wait", "milliseconds": 2000},
          {"type": "write", "text": "firecrawl"},
          {"type": "wait", "milliseconds": 2000},
          {"type": "press", "key": "ENTER"},
          {"type": "wait", "milliseconds": 3000},
          {"type": "click", "selector": "h3"},
          {"type": "wait", "milliseconds": 3000},
          {"type": "scrape"},
          {"type": "screenshot"}
      ]
  )
  print(scrape_result)
  ```

  ```js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape a website:
  const scrapeResult = await app.scrapeUrl('firecrawl.dev', { formats: ['markdown', 'html'], actions: [
      { type: "wait", milliseconds: 2000 },
      { type: "click", selector: "textarea[title=\"Search\"]" },
      { type: "wait", milliseconds: 2000 },
      { type: "write", text: "firecrawl" },
      { type: "wait", milliseconds: 2000 },
      { type: "press", key: "ENTER" },
      { type: "wait", milliseconds: 3000 },
      { type: "click", selector: "h3" },
      { type: "scrape" },
      {"type": "screenshot"}
  ] }) as ScrapeResponse;

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult)
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
          "url": "google.com",
          "formats": ["markdown"],
          "actions": [
              {"type": "wait", "milliseconds": 2000},
              {"type": "click", "selector": "textarea[title=\"Search\"]"},
              {"type": "wait", "milliseconds": 2000},
              {"type": "write", "text": "firecrawl"},
              {"type": "wait", "milliseconds": 2000},
              {"type": "press", "key": "ENTER"},
              {"type": "wait", "milliseconds": 3000},
              {"type": "click", "selector": "h3"},
              {"type": "wait", "milliseconds": 3000},
              {"type": "screenshot"}
          ]
      }'
  ```
</CodeGroup>

### Output

<CodeGroup>
  ```json JSON
  {
    "success": true,
    "data": {
      "markdown": "Our first Launch Week is over! [See the recap 🚀](blog/firecrawl-launch-week-1-recap)...",
      "actions": {
        "screenshots": [
          "https://alttmdsdujxrfnakrkyi.supabase.co/storage/v1/object/public/media/screenshot-75ef2d87-31e0-4349-a478-fb432a29e241.png"
        ],
        "scrapes": [
          {
            "url": "https://www.firecrawl.dev/",
            "html": "<html><body><h1>Firecrawl</h1></body></html>"
          }
        ]
      },
      "metadata": {
        "title": "Home - Firecrawl",
        "description": "Firecrawl crawls and converts any website into clean markdown.",
        "language": "en",
        "keywords": "Firecrawl,Markdown,Data,Mendable,Langchain",
        "robots": "follow, index",
        "ogTitle": "Firecrawl",
        "ogDescription": "Turn any website into LLM-ready data.",
        "ogUrl": "https://www.firecrawl.dev/",
        "ogImage": "https://www.firecrawl.dev/og.png?123",
        "ogLocaleAlternate": [],
        "ogSiteName": "Firecrawl",
        "sourceURL": "http://google.com",
        "statusCode": 200
      }
    }
  }
  ```
</CodeGroup>

For more details about the actions parameters, refer to the [API Reference](https://docs.firecrawl.dev/api-reference/endpoint/scrape).

## Location and Language

Specify country and preferred languages to get relevant content based on your target location and language preferences.

### How it works

When you specify the location settings, Firecrawl will use an appropriate proxy if available and emulate the corresponding language and timezone settings. By default, the location is set to 'US' if not specified.

### Usage

To use the location and language settings, include the `location` object in your request body with the following properties:

* `country`: ISO 3166-1 alpha-2 country code (e.g., 'US', 'AU', 'DE', 'JP'). Defaults to 'US'.
* `languages`: An array of preferred languages and locales for the request in order of priority. Defaults to the language of the specified location.

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape a website:
  scrape_result = app.scrape_url('airbnb.com', 
      formats=['markdown', 'html'], 
      location={
          'country': 'BR',
          'languages': ['pt-BR']
      }
  )
  print(scrape_result)
  ```

  ````js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape a website:
  const scrapeResult = await app.scrapeUrl('airbnb.com', { formats: ['markdown', 'html'], location: {
      country: "BR",
      languages: ["pt-BR"]
  } }) as ScrapeResponse;

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult)```
  ````

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
          "url": "airbnb.com",
          "formats": ["markdown"],
          "location": {
              "country": "BR",
              "languages": ["pt-BR"]
          }
      }'
  ```
</CodeGroup>

## Batch scraping multiple URLs

You can now batch scrape multiple URLs at the same time. It takes the starting URLs and optional parameters as arguments. The params argument allows you to specify additional options for the batch scrape job, such as the output formats.

### How it works

It is very similar to how the `/crawl` endpoint works. It submits a batch scrape job and returns a job ID to check the status of the batch scrape.

The sdk provides 2 methods, synchronous and asynchronous. The synchronous method will return the results of the batch scrape job, while the asynchronous method will return a job ID that you can use to check the status of the batch scrape.

### Usage

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape multiple websites:
  batch_scrape_result = app.batch_scrape_urls(['firecrawl.dev', 'mendable.ai'], formats=['markdown', 'html'])
  print(batch_scrape_result)

  # Or, you can use the asynchronous method:
  batch_scrape_job = app.async_batch_scrape_urls(['firecrawl.dev', 'mendable.ai'], formats=['markdown', 'html'])
  print(batch_scrape_job)

  # (async) You can then use the job ID to check the status of the batch scrape:
  batch_scrape_status = app.check_batch_scrape_status(batch_scrape_job.id)
  print(batch_scrape_status)
  ```

  ```js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape multiple websites (synchronous):
  const batchScrapeResult = await app.batchScrapeUrls(['firecrawl.dev', 'mendable.ai'], { formats: ['markdown', 'html'] });

  if (!batchScrapeResult.success) {
    throw new Error(`Failed to scrape: ${batchScrapeResult.error}`)
  }
  // Output all the results of the batch scrape:
  console.log(batchScrapeResult)

  // Or, you can use the asynchronous method:
  const batchScrapeJob = await app.asyncBulkScrapeUrls(['firecrawl.dev', 'mendable.ai'], { formats: ['markdown', 'html'] });
  console.log(batchScrapeJob)

  // (async) You can then use the job ID to check the status of the batch scrape:
  const batchScrapeStatus = await app.checkBatchScrapeStatus(batchScrapeJob.id);
  console.log(batchScrapeStatus)
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/batch/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "urls": ["https://docs.firecrawl.dev", "https://docs.firecrawl.dev/sdks/overview"],
        "formats" : ["markdown", "html"]
      }'
  ```
</CodeGroup>

### Response

If you’re using the sync methods from the SDKs, it will return the results of the batch scrape job. Otherwise, it will return a job ID that you can use to check the status of the batch scrape.

#### Synchronous

```json Completed
{
  "status": "completed",
  "total": 36,
  "completed": 36,
  "creditsUsed": 36,
  "expiresAt": "2024-00-00T00:00:00.000Z",
  "next": "https://api.firecrawl.dev/v1/batch/scrape/123-456-789?skip=26",
  "data": [
    {
      "markdown": "[Firecrawl Docs home page![light logo](https://mintlify.s3-us-west-1.amazonaws.com/firecrawl/logo/light.svg)!...",
      "html": "<!DOCTYPE html><html lang=\"en\" class=\"js-focus-visible lg:[--scroll-mt:9.5rem]\" data-js-focus-visible=\"\">...",
      "metadata": {
        "title": "Build a 'Chat with website' using Groq Llama 3 | Firecrawl",
        "language": "en",
        "sourceURL": "https://docs.firecrawl.dev/learn/rag-llama3",
        "description": "Learn how to use Firecrawl, Groq Llama 3, and Langchain to build a 'Chat with your website' bot.",
        "ogLocaleAlternate": [],
        "statusCode": 200
      }
    },
    ...
  ]
}
```

#### Asynchronous

You can then use the job ID to check the status of the batch scrape by calling the `/batch/scrape/{id}` endpoint. This endpoint is meant to be used while the job is still running or right after it has completed **as batch scrape jobs expire after 24 hours**.

```json
{
  "success": true,
  "id": "123-456-789",
  "url": "https://api.firecrawl.dev/v1/batch/scrape/123-456-789"
}
```

## Stealth Mode

For websites with advanced anti-bot protection, Firecrawl offers a stealth proxy mode that provides better success rates at scraping challenging sites.

Learn more about [Stealth Mode](/features/stealth-mode).

## Using FIRE-1 with Scrape

You can use the FIRE-1 agent with the `/scrape` endpoint to apply intelligent navigation before scraping the final content.

Activating FIRE-1 is straightforward. Simply include an `agent` object in your scrape or extract API request:

```json
"agent": {
  "model": "FIRE-1",
  "prompt": "Your detailed navigation instructions here."
}
```

*Note:* The `prompt` field is required for scrape requests, instructing FIRE-1 precisely how to interact with the webpage.

### Example Usage with Scrape Endpoint

Here's a quick example using FIRE-1 with the scrape endpoint to get the companies on the consumer space from Y Combinator:

```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -d '{
    "url": "https://ycombinator.com/companies",
    "formats": ["markdown"],
    "agent": {
      "model": "FIRE-1",
      "prompt": "Get W22 companies on the consumer space by clicking the respective buttons"
    }
  }'
```
# Scrape

> Turn any url into clean data

Firecrawl converts web pages into markdown, ideal for LLM applications.

* It manages complexities: proxies, caching, rate limits, js-blocked content
* Handles dynamic content: dynamic websites, js-rendered sites, PDFs, images
* Outputs clean markdown, structured data, screenshots or html.

For details, see the [Scrape Endpoint API Reference](https://docs.firecrawl.dev/api-reference/endpoint/scrape).

## Scraping a URL with Firecrawl

### /scrape endpoint

Used to scrape a URL and get its content.

### Installation

<CodeGroup>
  ```bash Python
  pip install firecrawl-py
  ```

  ```bash Node
  npm install @mendable/firecrawl-js
  ```

  ```bash Go
  go get github.com/mendableai/firecrawl-go
  ```

  ```yaml Rust
  # Add this to your Cargo.toml
  [dependencies]
  firecrawl = "^1.0"
  tokio = { version = "^1", features = ["full"] }
  ```
</CodeGroup>

### Usage

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape a website:
  scrape_result = app.scrape_url('firecrawl.dev', formats=['markdown', 'html'])
  print(scrape_result)
  ```

  ```js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape a website:
  const scrapeResult = await app.scrapeUrl('firecrawl.dev', { formats: ['markdown', 'html'] }) as ScrapeResponse;

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult)
  ```

  ```go Go
  import (
  	"fmt"
  	"log"

  	"github.com/mendableai/firecrawl-go"
  )

  func main() {
  	// Initialize the FirecrawlApp with your API key
  	apiKey := "fc-YOUR_API_KEY"
  	apiUrl := "https://api.firecrawl.dev"
  	version := "v1"

  	app, err := firecrawl.NewFirecrawlApp(apiKey, apiUrl, version)
  	if err != nil {
  		log.Fatalf("Failed to initialize FirecrawlApp: %v", err)
  	}

  	// Scrape a website
  	scrapeResult, err := app.ScrapeUrl("https://firecrawl.dev", map[string]any{
  		"formats": []string{"markdown", "html"},
  	})
  	if err != nil {
  		log.Fatalf("Failed to scrape URL: %v", err)
  	}

  	fmt.Println(scrapeResult)
  }
  ```

  ```rust Rust
  use firecrawl::{FirecrawlApp, scrape::{ScrapeOptions, ScrapeFormats}};

  #[tokio::main]
  async fn main() {
      // Initialize the FirecrawlApp with the API key
      let app = FirecrawlApp::new("fc-YOUR_API_KEY").expect("Failed to initialize FirecrawlApp");

      let options = ScrapeOptions {
          formats vec! [ ScrapeFormats::Markdown, ScrapeFormats::HTML ].into(),
          ..Default::default()
      };

      let scrape_result = app.scrape_url("https://firecrawl.dev", options).await;

      match scrape_result {
          Ok(data) => println!("Scrape Result:\n{}", data.markdown.unwrap()),
          Err(e) => eprintln!("Map failed: {}", e),
      }
  }
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "url": "https://docs.firecrawl.dev",
        "formats" : ["markdown", "html"]
      }'
  ```
</CodeGroup>

For more details about the parameters, refer to the [API Reference](https://docs.firecrawl.dev/api-reference/endpoint/scrape).

### Response

SDKs will return the data object directly. cURL will return the payload exactly as shown below.

```json
{
  "success": true,
  "data" : {
    "markdown": "Launch Week I is here! [See our Day 2 Release 🚀](https://www.firecrawl.dev/blog/launch-week-i-day-2-doubled-rate-limits)[💥 Get 2 months free...",
    "html": "<!DOCTYPE html><html lang=\"en\" class=\"light\" style=\"color-scheme: light;\"><body class=\"__variable_36bd41 __variable_d7dc5d font-inter ...",
    "metadata": {
      "title": "Home - Firecrawl",
      "description": "Firecrawl crawls and converts any website into clean markdown.",
      "language": "en",
      "keywords": "Firecrawl,Markdown,Data,Mendable,Langchain",
      "robots": "follow, index",
      "ogTitle": "Firecrawl",
      "ogDescription": "Turn any website into LLM-ready data.",
      "ogUrl": "https://www.firecrawl.dev/",
      "ogImage": "https://www.firecrawl.dev/og.png?123",
      "ogLocaleAlternate": [],
      "ogSiteName": "Firecrawl",
      "sourceURL": "https://firecrawl.dev",
      "statusCode": 200
    }
  }
}
```

## Scrape Formats

You can now choose what formats you want your output in. You can specify multiple output formats. Supported formats are:

* Markdown (markdown)
* HTML (html)
* Raw HTML (rawHtml) (with no modifications)
* Screenshot (screenshot or screenshot\@fullPage)
* Links (links)
* JSON (json) - structured output

Output keys will match the format you choose.

## Extract structured data

### /scrape (with json) endpoint

Used to extract structured data from scraped pages.

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp, JsonConfig
  from pydantic import BaseModel, Field

  # Initialize the FirecrawlApp with your API key
  app = FirecrawlApp(api_key='your_api_key')

  class ExtractSchema(BaseModel):
      company_mission: str
      supports_sso: bool
      is_open_source: bool
      is_in_yc: bool

  json_config = JsonConfig(
      extractionSchema=ExtractSchema.model_json_schema(),
      mode="llm-extraction",
      pageOptions={"onlyMainContent": True}
  )

  llm_extraction_result = app.scrape_url(
      'https://firecrawl.dev',
      formats=["json"],
      json_options=json_config
  )
  print(llm_extraction_result)
  ```

  ```js Node
  import FirecrawlApp from "@mendable/firecrawl-js";
  import { z } from "zod";

  const app = new FirecrawlApp({
    apiKey: "fc-YOUR_API_KEY"
  });

  // Define schema to extract contents into
  const schema = z.object({
    company_mission: z.string(),
    supports_sso: z.boolean(),
    is_open_source: z.boolean(),
    is_in_yc: z.boolean()
  });

  const scrapeResult = await app.scrapeUrl("https://docs.firecrawl.dev/", {
    formats: ["json"],
    jsonOptions: { schema: schema }
  });

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult.json);
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "url": "https://docs.firecrawl.dev/",
        "formats": ["json"],
        "jsonOptions": {
          "schema": {
            "type": "object",
            "properties": {
              "company_mission": {
                        "type": "string"
              },
              "supports_sso": {
                        "type": "boolean"
              },
              "is_open_source": {
                        "type": "boolean"
              },
              "is_in_yc": {
                        "type": "boolean"
              }
            },
            "required": [
              "company_mission",
              "supports_sso",
              "is_open_source",
              "is_in_yc"
            ]
          }
        }
      }'
  ```
</CodeGroup>

Output:

```json JSON
{
    "success": true,
    "data": {
      "json": {
        "company_mission": "AI-powered web scraping and data extraction",
        "supports_sso": true,
        "is_open_source": true,
        "is_in_yc": true
      },
      "metadata": {
        "title": "Firecrawl",
        "description": "AI-powered web scraping and data extraction",
        "robots": "follow, index",
        "ogTitle": "Firecrawl",
        "ogDescription": "AI-powered web scraping and data extraction",
        "ogUrl": "https://firecrawl.dev/",
        "ogImage": "https://firecrawl.dev/og.png",
        "ogLocaleAlternate": [],
        "ogSiteName": "Firecrawl",
        "sourceURL": "https://firecrawl.dev/"
      },
    }
}
```

### Extracting without schema (New)

You can now extract without a schema by just passing a `prompt` to the endpoint. The llm chooses the structure of the data.

<CodeGroup>
  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "url": "https://docs.firecrawl.dev/",
        "formats": ["json"],
        "jsonOptions": {
          "prompt": "Extract the company mission from the page."
        }
      }'
  ```
</CodeGroup>

Output:

```json JSON
{
    "success": true,
    "data": {
      "json": {
        "company_mission": "AI-powered web scraping and data extraction",
      },
      "metadata": {
        "title": "Firecrawl",
        "description": "AI-powered web scraping and data extraction",
        "robots": "follow, index",
        "ogTitle": "Firecrawl",
        "ogDescription": "AI-powered web scraping and data extraction",
        "ogUrl": "https://firecrawl.dev/",
        "ogImage": "https://firecrawl.dev/og.png",
        "ogLocaleAlternate": [],
        "ogSiteName": "Firecrawl",
        "sourceURL": "https://firecrawl.dev/"
      },
    }
}
```

### JSON options object

The `jsonOptions` object accepts the following parameters:

* `schema`: The schema to use for the extraction.
* `systemPrompt`: The system prompt to use for the extraction.
* `prompt`: The prompt to use for the extraction without a schema.

## Interacting with the page with Actions

Firecrawl allows you to perform various actions on a web page before scraping its content. This is particularly useful for interacting with dynamic content, navigating through pages, or accessing content that requires user interaction.

Here is an example of how to use actions to navigate to google.com, search for Firecrawl, click on the first result, and take a screenshot.

It is important to almost always use the `wait` action before/after executing other actions to give enough time for the page to load.

### Example

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape a website:
  scrape_result = app.scrape_url('firecrawl.dev', 
      formats=['markdown', 'html'], 
      actions=[
          {"type": "wait", "milliseconds": 2000},
          {"type": "click", "selector": "textarea[title=\"Search\"]"},
          {"type": "wait", "milliseconds": 2000},
          {"type": "write", "text": "firecrawl"},
          {"type": "wait", "milliseconds": 2000},
          {"type": "press", "key": "ENTER"},
          {"type": "wait", "milliseconds": 3000},
          {"type": "click", "selector": "h3"},
          {"type": "wait", "milliseconds": 3000},
          {"type": "scrape"},
          {"type": "screenshot"}
      ]
  )
  print(scrape_result)
  ```

  ```js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape a website:
  const scrapeResult = await app.scrapeUrl('firecrawl.dev', { formats: ['markdown', 'html'], actions: [
      { type: "wait", milliseconds: 2000 },
      { type: "click", selector: "textarea[title=\"Search\"]" },
      { type: "wait", milliseconds: 2000 },
      { type: "write", text: "firecrawl" },
      { type: "wait", milliseconds: 2000 },
      { type: "press", key: "ENTER" },
      { type: "wait", milliseconds: 3000 },
      { type: "click", selector: "h3" },
      { type: "scrape" },
      {"type": "screenshot"}
  ] }) as ScrapeResponse;

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult)
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
          "url": "google.com",
          "formats": ["markdown"],
          "actions": [
              {"type": "wait", "milliseconds": 2000},
              {"type": "click", "selector": "textarea[title=\"Search\"]"},
              {"type": "wait", "milliseconds": 2000},
              {"type": "write", "text": "firecrawl"},
              {"type": "wait", "milliseconds": 2000},
              {"type": "press", "key": "ENTER"},
              {"type": "wait", "milliseconds": 3000},
              {"type": "click", "selector": "h3"},
              {"type": "wait", "milliseconds": 3000},
              {"type": "screenshot"}
          ]
      }'
  ```
</CodeGroup>

### Output

<CodeGroup>
  ```json JSON
  {
    "success": true,
    "data": {
      "markdown": "Our first Launch Week is over! [See the recap 🚀](blog/firecrawl-launch-week-1-recap)...",
      "actions": {
        "screenshots": [
          "https://alttmdsdujxrfnakrkyi.supabase.co/storage/v1/object/public/media/screenshot-75ef2d87-31e0-4349-a478-fb432a29e241.png"
        ],
        "scrapes": [
          {
            "url": "https://www.firecrawl.dev/",
            "html": "<html><body><h1>Firecrawl</h1></body></html>"
          }
        ]
      },
      "metadata": {
        "title": "Home - Firecrawl",
        "description": "Firecrawl crawls and converts any website into clean markdown.",
        "language": "en",
        "keywords": "Firecrawl,Markdown,Data,Mendable,Langchain",
        "robots": "follow, index",
        "ogTitle": "Firecrawl",
        "ogDescription": "Turn any website into LLM-ready data.",
        "ogUrl": "https://www.firecrawl.dev/",
        "ogImage": "https://www.firecrawl.dev/og.png?123",
        "ogLocaleAlternate": [],
        "ogSiteName": "Firecrawl",
        "sourceURL": "http://google.com",
        "statusCode": 200
      }
    }
  }
  ```
</CodeGroup>

For more details about the actions parameters, refer to the [API Reference](https://docs.firecrawl.dev/api-reference/endpoint/scrape).

## Location and Language

Specify country and preferred languages to get relevant content based on your target location and language preferences.

### How it works

When you specify the location settings, Firecrawl will use an appropriate proxy if available and emulate the corresponding language and timezone settings. By default, the location is set to 'US' if not specified.

### Usage

To use the location and language settings, include the `location` object in your request body with the following properties:

* `country`: ISO 3166-1 alpha-2 country code (e.g., 'US', 'AU', 'DE', 'JP'). Defaults to 'US'.
* `languages`: An array of preferred languages and locales for the request in order of priority. Defaults to the language of the specified location.

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape a website:
  scrape_result = app.scrape_url('airbnb.com', 
      formats=['markdown', 'html'], 
      location={
          'country': 'BR',
          'languages': ['pt-BR']
      }
  )
  print(scrape_result)
  ```

  ````js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape a website:
  const scrapeResult = await app.scrapeUrl('airbnb.com', { formats: ['markdown', 'html'], location: {
      country: "BR",
      languages: ["pt-BR"]
  } }) as ScrapeResponse;

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult)```
  ````

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
          "url": "airbnb.com",
          "formats": ["markdown"],
          "location": {
              "country": "BR",
              "languages": ["pt-BR"]
          }
      }'
  ```
</CodeGroup>

## Batch scraping multiple URLs

You can now batch scrape multiple URLs at the same time. It takes the starting URLs and optional parameters as arguments. The params argument allows you to specify additional options for the batch scrape job, such as the output formats.

### How it works

It is very similar to how the `/crawl` endpoint works. It submits a batch scrape job and returns a job ID to check the status of the batch scrape.

The sdk provides 2 methods, synchronous and asynchronous. The synchronous method will return the results of the batch scrape job, while the asynchronous method will return a job ID that you can use to check the status of the batch scrape.

### Usage

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape multiple websites:
  batch_scrape_result = app.batch_scrape_urls(['firecrawl.dev', 'mendable.ai'], formats=['markdown', 'html'])
  print(batch_scrape_result)

  # Or, you can use the asynchronous method:
  batch_scrape_job = app.async_batch_scrape_urls(['firecrawl.dev', 'mendable.ai'], formats=['markdown', 'html'])
  print(batch_scrape_job)

  # (async) You can then use the job ID to check the status of the batch scrape:
  batch_scrape_status = app.check_batch_scrape_status(batch_scrape_job.id)
  print(batch_scrape_status)
  ```

  ```js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape multiple websites (synchronous):
  const batchScrapeResult = await app.batchScrapeUrls(['firecrawl.dev', 'mendable.ai'], { formats: ['markdown', 'html'] });

  if (!batchScrapeResult.success) {
    throw new Error(`Failed to scrape: ${batchScrapeResult.error}`)
  }
  // Output all the results of the batch scrape:
  console.log(batchScrapeResult)

  // Or, you can use the asynchronous method:
  const batchScrapeJob = await app.asyncBulkScrapeUrls(['firecrawl.dev', 'mendable.ai'], { formats: ['markdown', 'html'] });
  console.log(batchScrapeJob)

  // (async) You can then use the job ID to check the status of the batch scrape:
  const batchScrapeStatus = await app.checkBatchScrapeStatus(batchScrapeJob.id);
  console.log(batchScrapeStatus)
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/batch/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "urls": ["https://docs.firecrawl.dev", "https://docs.firecrawl.dev/sdks/overview"],
        "formats" : ["markdown", "html"]
      }'
  ```
</CodeGroup>

### Response

If you’re using the sync methods from the SDKs, it will return the results of the batch scrape job. Otherwise, it will return a job ID that you can use to check the status of the batch scrape.

#### Synchronous

```json Completed
{
  "status": "completed",
  "total": 36,
  "completed": 36,
  "creditsUsed": 36,
  "expiresAt": "2024-00-00T00:00:00.000Z",
  "next": "https://api.firecrawl.dev/v1/batch/scrape/123-456-789?skip=26",
  "data": [
    {
      "markdown": "[Firecrawl Docs home page![light logo](https://mintlify.s3-us-west-1.amazonaws.com/firecrawl/logo/light.svg)!...",
      "html": "<!DOCTYPE html><html lang=\"en\" class=\"js-focus-visible lg:[--scroll-mt:9.5rem]\" data-js-focus-visible=\"\">...",
      "metadata": {
        "title": "Build a 'Chat with website' using Groq Llama 3 | Firecrawl",
        "language": "en",
        "sourceURL": "https://docs.firecrawl.dev/learn/rag-llama3",
        "description": "Learn how to use Firecrawl, Groq Llama 3, and Langchain to build a 'Chat with your website' bot.",
        "ogLocaleAlternate": [],
        "statusCode": 200
      }
    },
    ...
  ]
}
```

#### Asynchronous

You can then use the job ID to check the status of the batch scrape by calling the `/batch/scrape/{id}` endpoint. This endpoint is meant to be used while the job is still running or right after it has completed **as batch scrape jobs expire after 24 hours**.

```json
{
  "success": true,
  "id": "123-456-789",
  "url": "https://api.firecrawl.dev/v1/batch/scrape/123-456-789"
}
```

## Stealth Mode

For websites with advanced anti-bot protection, Firecrawl offers a stealth proxy mode that provides better success rates at scraping challenging sites.

Learn more about [Stealth Mode](/features/stealth-mode).

## Using FIRE-1 with Scrape

You can use the FIRE-1 agent with the `/scrape` endpoint to apply intelligent navigation before scraping the final content.

Activating FIRE-1 is straightforward. Simply include an `agent` object in your scrape or extract API request:

```json
"agent": {
  "model": "FIRE-1",
  "prompt": "Your detailed navigation instructions here."
}
```

*Note:* The `prompt` field is required for scrape requests, instructing FIRE-1 precisely how to interact with the webpage.

### Example Usage with Scrape Endpoint

Here's a quick example using FIRE-1 with the scrape endpoint to get the companies on the consumer space from Y Combinator:

```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -d '{
    "url": "https://ycombinator.com/companies",
    "formats": ["markdown"],
    "agent": {
      "model": "FIRE-1",
      "prompt": "Get W22 companies on the consumer space by clicking the respective buttons"
    }
  }'
```
# Scrape

> Turn any url into clean data

Firecrawl converts web pages into markdown, ideal for LLM applications.

* It manages complexities: proxies, caching, rate limits, js-blocked content
* Handles dynamic content: dynamic websites, js-rendered sites, PDFs, images
* Outputs clean markdown, structured data, screenshots or html.

For details, see the [Scrape Endpoint API Reference](https://docs.firecrawl.dev/api-reference/endpoint/scrape).

## Scraping a URL with Firecrawl

### /scrape endpoint

Used to scrape a URL and get its content.

### Installation

<CodeGroup>
  ```bash Python
  pip install firecrawl-py
  ```

  ```bash Node
  npm install @mendable/firecrawl-js
  ```

  ```bash Go
  go get github.com/mendableai/firecrawl-go
  ```

  ```yaml Rust
  # Add this to your Cargo.toml
  [dependencies]
  firecrawl = "^1.0"
  tokio = { version = "^1", features = ["full"] }
  ```
</CodeGroup>

### Usage

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape a website:
  scrape_result = app.scrape_url('firecrawl.dev', formats=['markdown', 'html'])
  print(scrape_result)
  ```

  ```js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape a website:
  const scrapeResult = await app.scrapeUrl('firecrawl.dev', { formats: ['markdown', 'html'] }) as ScrapeResponse;

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult)
  ```

  ```go Go
  import (
  	"fmt"
  	"log"

  	"github.com/mendableai/firecrawl-go"
  )

  func main() {
  	// Initialize the FirecrawlApp with your API key
  	apiKey := "fc-YOUR_API_KEY"
  	apiUrl := "https://api.firecrawl.dev"
  	version := "v1"

  	app, err := firecrawl.NewFirecrawlApp(apiKey, apiUrl, version)
  	if err != nil {
  		log.Fatalf("Failed to initialize FirecrawlApp: %v", err)
  	}

  	// Scrape a website
  	scrapeResult, err := app.ScrapeUrl("https://firecrawl.dev", map[string]any{
  		"formats": []string{"markdown", "html"},
  	})
  	if err != nil {
  		log.Fatalf("Failed to scrape URL: %v", err)
  	}

  	fmt.Println(scrapeResult)
  }
  ```

  ```rust Rust
  use firecrawl::{FirecrawlApp, scrape::{ScrapeOptions, ScrapeFormats}};

  #[tokio::main]
  async fn main() {
      // Initialize the FirecrawlApp with the API key
      let app = FirecrawlApp::new("fc-YOUR_API_KEY").expect("Failed to initialize FirecrawlApp");

      let options = ScrapeOptions {
          formats vec! [ ScrapeFormats::Markdown, ScrapeFormats::HTML ].into(),
          ..Default::default()
      };

      let scrape_result = app.scrape_url("https://firecrawl.dev", options).await;

      match scrape_result {
          Ok(data) => println!("Scrape Result:\n{}", data.markdown.unwrap()),
          Err(e) => eprintln!("Map failed: {}", e),
      }
  }
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "url": "https://docs.firecrawl.dev",
        "formats" : ["markdown", "html"]
      }'
  ```
</CodeGroup>

For more details about the parameters, refer to the [API Reference](https://docs.firecrawl.dev/api-reference/endpoint/scrape).

### Response

SDKs will return the data object directly. cURL will return the payload exactly as shown below.

```json
{
  "success": true,
  "data" : {
    "markdown": "Launch Week I is here! [See our Day 2 Release 🚀](https://www.firecrawl.dev/blog/launch-week-i-day-2-doubled-rate-limits)[💥 Get 2 months free...",
    "html": "<!DOCTYPE html><html lang=\"en\" class=\"light\" style=\"color-scheme: light;\"><body class=\"__variable_36bd41 __variable_d7dc5d font-inter ...",
    "metadata": {
      "title": "Home - Firecrawl",
      "description": "Firecrawl crawls and converts any website into clean markdown.",
      "language": "en",
      "keywords": "Firecrawl,Markdown,Data,Mendable,Langchain",
      "robots": "follow, index",
      "ogTitle": "Firecrawl",
      "ogDescription": "Turn any website into LLM-ready data.",
      "ogUrl": "https://www.firecrawl.dev/",
      "ogImage": "https://www.firecrawl.dev/og.png?123",
      "ogLocaleAlternate": [],
      "ogSiteName": "Firecrawl",
      "sourceURL": "https://firecrawl.dev",
      "statusCode": 200
    }
  }
}
```

## Scrape Formats

You can now choose what formats you want your output in. You can specify multiple output formats. Supported formats are:

* Markdown (markdown)
* HTML (html)
* Raw HTML (rawHtml) (with no modifications)
* Screenshot (screenshot or screenshot\@fullPage)
* Links (links)
* JSON (json) - structured output

Output keys will match the format you choose.

## Extract structured data

### /scrape (with json) endpoint

Used to extract structured data from scraped pages.

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp, JsonConfig
  from pydantic import BaseModel, Field

  # Initialize the FirecrawlApp with your API key
  app = FirecrawlApp(api_key='your_api_key')

  class ExtractSchema(BaseModel):
      company_mission: str
      supports_sso: bool
      is_open_source: bool
      is_in_yc: bool

  json_config = JsonConfig(
      extractionSchema=ExtractSchema.model_json_schema(),
      mode="llm-extraction",
      pageOptions={"onlyMainContent": True}
  )

  llm_extraction_result = app.scrape_url(
      'https://firecrawl.dev',
      formats=["json"],
      json_options=json_config
  )
  print(llm_extraction_result)
  ```

  ```js Node
  import FirecrawlApp from "@mendable/firecrawl-js";
  import { z } from "zod";

  const app = new FirecrawlApp({
    apiKey: "fc-YOUR_API_KEY"
  });

  // Define schema to extract contents into
  const schema = z.object({
    company_mission: z.string(),
    supports_sso: z.boolean(),
    is_open_source: z.boolean(),
    is_in_yc: z.boolean()
  });

  const scrapeResult = await app.scrapeUrl("https://docs.firecrawl.dev/", {
    formats: ["json"],
    jsonOptions: { schema: schema }
  });

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult.json);
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "url": "https://docs.firecrawl.dev/",
        "formats": ["json"],
        "jsonOptions": {
          "schema": {
            "type": "object",
            "properties": {
              "company_mission": {
                        "type": "string"
              },
              "supports_sso": {
                        "type": "boolean"
              },
              "is_open_source": {
                        "type": "boolean"
              },
              "is_in_yc": {
                        "type": "boolean"
              }
            },
            "required": [
              "company_mission",
              "supports_sso",
              "is_open_source",
              "is_in_yc"
            ]
          }
        }
      }'
  ```
</CodeGroup>

Output:

```json JSON
{
    "success": true,
    "data": {
      "json": {
        "company_mission": "AI-powered web scraping and data extraction",
        "supports_sso": true,
        "is_open_source": true,
        "is_in_yc": true
      },
      "metadata": {
        "title": "Firecrawl",
        "description": "AI-powered web scraping and data extraction",
        "robots": "follow, index",
        "ogTitle": "Firecrawl",
        "ogDescription": "AI-powered web scraping and data extraction",
        "ogUrl": "https://firecrawl.dev/",
        "ogImage": "https://firecrawl.dev/og.png",
        "ogLocaleAlternate": [],
        "ogSiteName": "Firecrawl",
        "sourceURL": "https://firecrawl.dev/"
      },
    }
}
```

### Extracting without schema (New)

You can now extract without a schema by just passing a `prompt` to the endpoint. The llm chooses the structure of the data.

<CodeGroup>
  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "url": "https://docs.firecrawl.dev/",
        "formats": ["json"],
        "jsonOptions": {
          "prompt": "Extract the company mission from the page."
        }
      }'
  ```
</CodeGroup>

Output:

```json JSON
{
    "success": true,
    "data": {
      "json": {
        "company_mission": "AI-powered web scraping and data extraction",
      },
      "metadata": {
        "title": "Firecrawl",
        "description": "AI-powered web scraping and data extraction",
        "robots": "follow, index",
        "ogTitle": "Firecrawl",
        "ogDescription": "AI-powered web scraping and data extraction",
        "ogUrl": "https://firecrawl.dev/",
        "ogImage": "https://firecrawl.dev/og.png",
        "ogLocaleAlternate": [],
        "ogSiteName": "Firecrawl",
        "sourceURL": "https://firecrawl.dev/"
      },
    }
}
```

### JSON options object

The `jsonOptions` object accepts the following parameters:

* `schema`: The schema to use for the extraction.
* `systemPrompt`: The system prompt to use for the extraction.
* `prompt`: The prompt to use for the extraction without a schema.

## Interacting with the page with Actions

Firecrawl allows you to perform various actions on a web page before scraping its content. This is particularly useful for interacting with dynamic content, navigating through pages, or accessing content that requires user interaction.

Here is an example of how to use actions to navigate to google.com, search for Firecrawl, click on the first result, and take a screenshot.

It is important to almost always use the `wait` action before/after executing other actions to give enough time for the page to load.

### Example

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape a website:
  scrape_result = app.scrape_url('firecrawl.dev', 
      formats=['markdown', 'html'], 
      actions=[
          {"type": "wait", "milliseconds": 2000},
          {"type": "click", "selector": "textarea[title=\"Search\"]"},
          {"type": "wait", "milliseconds": 2000},
          {"type": "write", "text": "firecrawl"},
          {"type": "wait", "milliseconds": 2000},
          {"type": "press", "key": "ENTER"},
          {"type": "wait", "milliseconds": 3000},
          {"type": "click", "selector": "h3"},
          {"type": "wait", "milliseconds": 3000},
          {"type": "scrape"},
          {"type": "screenshot"}
      ]
  )
  print(scrape_result)
  ```

  ```js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape a website:
  const scrapeResult = await app.scrapeUrl('firecrawl.dev', { formats: ['markdown', 'html'], actions: [
      { type: "wait", milliseconds: 2000 },
      { type: "click", selector: "textarea[title=\"Search\"]" },
      { type: "wait", milliseconds: 2000 },
      { type: "write", text: "firecrawl" },
      { type: "wait", milliseconds: 2000 },
      { type: "press", key: "ENTER" },
      { type: "wait", milliseconds: 3000 },
      { type: "click", selector: "h3" },
      { type: "scrape" },
      {"type": "screenshot"}
  ] }) as ScrapeResponse;

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult)
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
          "url": "google.com",
          "formats": ["markdown"],
          "actions": [
              {"type": "wait", "milliseconds": 2000},
              {"type": "click", "selector": "textarea[title=\"Search\"]"},
              {"type": "wait", "milliseconds": 2000},
              {"type": "write", "text": "firecrawl"},
              {"type": "wait", "milliseconds": 2000},
              {"type": "press", "key": "ENTER"},
              {"type": "wait", "milliseconds": 3000},
              {"type": "click", "selector": "h3"},
              {"type": "wait", "milliseconds": 3000},
              {"type": "screenshot"}
          ]
      }'
  ```
</CodeGroup>

### Output

<CodeGroup>
  ```json JSON
  {
    "success": true,
    "data": {
      "markdown": "Our first Launch Week is over! [See the recap 🚀](blog/firecrawl-launch-week-1-recap)...",
      "actions": {
        "screenshots": [
          "https://alttmdsdujxrfnakrkyi.supabase.co/storage/v1/object/public/media/screenshot-75ef2d87-31e0-4349-a478-fb432a29e241.png"
        ],
        "scrapes": [
          {
            "url": "https://www.firecrawl.dev/",
            "html": "<html><body><h1>Firecrawl</h1></body></html>"
          }
        ]
      },
      "metadata": {
        "title": "Home - Firecrawl",
        "description": "Firecrawl crawls and converts any website into clean markdown.",
        "language": "en",
        "keywords": "Firecrawl,Markdown,Data,Mendable,Langchain",
        "robots": "follow, index",
        "ogTitle": "Firecrawl",
        "ogDescription": "Turn any website into LLM-ready data.",
        "ogUrl": "https://www.firecrawl.dev/",
        "ogImage": "https://www.firecrawl.dev/og.png?123",
        "ogLocaleAlternate": [],
        "ogSiteName": "Firecrawl",
        "sourceURL": "http://google.com",
        "statusCode": 200
      }
    }
  }
  ```
</CodeGroup>

For more details about the actions parameters, refer to the [API Reference](https://docs.firecrawl.dev/api-reference/endpoint/scrape).

## Location and Language

Specify country and preferred languages to get relevant content based on your target location and language preferences.

### How it works

When you specify the location settings, Firecrawl will use an appropriate proxy if available and emulate the corresponding language and timezone settings. By default, the location is set to 'US' if not specified.

### Usage

To use the location and language settings, include the `location` object in your request body with the following properties:

* `country`: ISO 3166-1 alpha-2 country code (e.g., 'US', 'AU', 'DE', 'JP'). Defaults to 'US'.
* `languages`: An array of preferred languages and locales for the request in order of priority. Defaults to the language of the specified location.

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape a website:
  scrape_result = app.scrape_url('airbnb.com', 
      formats=['markdown', 'html'], 
      location={
          'country': 'BR',
          'languages': ['pt-BR']
      }
  )
  print(scrape_result)
  ```

  ````js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape a website:
  const scrapeResult = await app.scrapeUrl('airbnb.com', { formats: ['markdown', 'html'], location: {
      country: "BR",
      languages: ["pt-BR"]
  } }) as ScrapeResponse;

  if (!scrapeResult.success) {
    throw new Error(`Failed to scrape: ${scrapeResult.error}`)
  }

  console.log(scrapeResult)```
  ````

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
          "url": "airbnb.com",
          "formats": ["markdown"],
          "location": {
              "country": "BR",
              "languages": ["pt-BR"]
          }
      }'
  ```
</CodeGroup>

## Batch scraping multiple URLs

You can now batch scrape multiple URLs at the same time. It takes the starting URLs and optional parameters as arguments. The params argument allows you to specify additional options for the batch scrape job, such as the output formats.

### How it works

It is very similar to how the `/crawl` endpoint works. It submits a batch scrape job and returns a job ID to check the status of the batch scrape.

The sdk provides 2 methods, synchronous and asynchronous. The synchronous method will return the results of the batch scrape job, while the asynchronous method will return a job ID that you can use to check the status of the batch scrape.

### Usage

<CodeGroup>
  ```python Python
  from firecrawl import FirecrawlApp

  app = FirecrawlApp(api_key="fc-YOUR_API_KEY")

  # Scrape multiple websites:
  batch_scrape_result = app.batch_scrape_urls(['firecrawl.dev', 'mendable.ai'], formats=['markdown', 'html'])
  print(batch_scrape_result)

  # Or, you can use the asynchronous method:
  batch_scrape_job = app.async_batch_scrape_urls(['firecrawl.dev', 'mendable.ai'], formats=['markdown', 'html'])
  print(batch_scrape_job)

  # (async) You can then use the job ID to check the status of the batch scrape:
  batch_scrape_status = app.check_batch_scrape_status(batch_scrape_job.id)
  print(batch_scrape_status)
  ```

  ```js Node
  import FirecrawlApp, { ScrapeResponse } from '@mendable/firecrawl-js';

  const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

  // Scrape multiple websites (synchronous):
  const batchScrapeResult = await app.batchScrapeUrls(['firecrawl.dev', 'mendable.ai'], { formats: ['markdown', 'html'] });

  if (!batchScrapeResult.success) {
    throw new Error(`Failed to scrape: ${batchScrapeResult.error}`)
  }
  // Output all the results of the batch scrape:
  console.log(batchScrapeResult)

  // Or, you can use the asynchronous method:
  const batchScrapeJob = await app.asyncBulkScrapeUrls(['firecrawl.dev', 'mendable.ai'], { formats: ['markdown', 'html'] });
  console.log(batchScrapeJob)

  // (async) You can then use the job ID to check the status of the batch scrape:
  const batchScrapeStatus = await app.checkBatchScrapeStatus(batchScrapeJob.id);
  console.log(batchScrapeStatus)
  ```

  ```bash cURL
  curl -X POST https://api.firecrawl.dev/v1/batch/scrape \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer YOUR_API_KEY' \
      -d '{
        "urls": ["https://docs.firecrawl.dev", "https://docs.firecrawl.dev/sdks/overview"],
        "formats" : ["markdown", "html"]
      }'
  ```
</CodeGroup>

### Response

If you’re using the sync methods from the SDKs, it will return the results of the batch scrape job. Otherwise, it will return a job ID that you can use to check the status of the batch scrape.

#### Synchronous

```json Completed
{
  "status": "completed",
  "total": 36,
  "completed": 36,
  "creditsUsed": 36,
  "expiresAt": "2024-00-00T00:00:00.000Z",
  "next": "https://api.firecrawl.dev/v1/batch/scrape/123-456-789?skip=26",
  "data": [
    {
      "markdown": "[Firecrawl Docs home page![light logo](https://mintlify.s3-us-west-1.amazonaws.com/firecrawl/logo/light.svg)!...",
      "html": "<!DOCTYPE html><html lang=\"en\" class=\"js-focus-visible lg:[--scroll-mt:9.5rem]\" data-js-focus-visible=\"\">...",
      "metadata": {
        "title": "Build a 'Chat with website' using Groq Llama 3 | Firecrawl",
        "language": "en",
        "sourceURL": "https://docs.firecrawl.dev/learn/rag-llama3",
        "description": "Learn how to use Firecrawl, Groq Llama 3, and Langchain to build a 'Chat with your website' bot.",
        "ogLocaleAlternate": [],
        "statusCode": 200
      }
    },
    ...
  ]
}
```

#### Asynchronous

You can then use the job ID to check the status of the batch scrape by calling the `/batch/scrape/{id}` endpoint. This endpoint is meant to be used while the job is still running or right after it has completed **as batch scrape jobs expire after 24 hours**.

```json
{
  "success": true,
  "id": "123-456-789",
  "url": "https://api.firecrawl.dev/v1/batch/scrape/123-456-789"
}
```

## Stealth Mode

For websites with advanced anti-bot protection, Firecrawl offers a stealth proxy mode that provides better success rates at scraping challenging sites.

Learn more about [Stealth Mode](/features/stealth-mode).

## Using FIRE-1 with Scrape

You can use the FIRE-1 agent with the `/scrape` endpoint to apply intelligent navigation before scraping the final content.

Activating FIRE-1 is straightforward. Simply include an `agent` object in your scrape or extract API request:

```json
"agent": {
  "model": "FIRE-1",
  "prompt": "Your detailed navigation instructions here."
}
```

*Note:* The `prompt` field is required for scrape requests, instructing FIRE-1 precisely how to interact with the webpage.

### Example Usage with Scrape Endpoint

Here's a quick example using FIRE-1 with the scrape endpoint to get the companies on the consumer space from Y Combinator:

```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -d '{
    "url": "https://ycombinator.com/companies",
    "formats": ["markdown"],
    "agent": {
      "model": "FIRE-1",
      "prompt": "Get W22 companies on the consumer space by clicking the respective buttons"
    }
  }'
```
