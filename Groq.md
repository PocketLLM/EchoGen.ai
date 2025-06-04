Quickstart
Get up and running with the Groq API in a few minutes.

Create an API Key
Please visit here to create an API Key.

Set up your API Key (recommended)
Configure your API key as an environment variable. This approach streamlines your API usage by eliminating the need to include your API key in each request. Moreover, it enhances security by minimizing the risk of inadvertently including your API key in your codebase.

In your terminal of choice:

export GROQ_API_KEY=<your-api-key-here>
Requesting your first chat completion
curl
JavaScript
Python
JSON
Install the Groq JavaScript library:

npm install --save groq-sdk
Performing a Chat Completion:

import Groq from "groq-sdk";

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export async function main() {
  const chatCompletion = await getGroqChatCompletion();
  // Print the completion returned by the LLM.
  console.log(chatCompletion.choices[0]?.message?.content || "");
}

export async function getGroqChatCompletion() {
  return groq.chat.completions.create({
    messages: [
      {
        role: "user",
        content: "Explain the importance of fast language models",
      },
    ],
    model: "llama-3.3-70b-versatile",
  });
}
Using third-party libraries and SDKs
Vercel AI SDK
LiteLLM
LangChain
Using AI SDK:
AI SDK is a Javascript-based open-source library that simplifies building large language model (LLM) applications. Documentation for how to use Groq on the AI SDK can be found here.


First, install the ai package and the Groq provider @ai-sdk/groq:



pnpm add ai @ai-sdk/groq

Then, you can use the Groq provider to generate text. By default, the provider will look for GROQ_API_KEY as the API key.



import { groq } from '@ai-sdk/groq';
import { generateText } from 'ai';

const { text } = await generateText({
  model: groq('llama-3.3-70b-versatile'),
  prompt: 'Write a vegetarian lasagna recipe for 4 people.',
});
Now that you have successfully received a chat completion, you can try out the other endpoints in the API.
OpenAI Compatibility

We designed Groq API to be mostly compatible with OpenAI's client libraries, making it easy to configure your existing applications to run on Groq and try our inference speed.

We also have our own Groq Python and Groq TypeScript libraries that we encourage you to use.

Configuring OpenAI to Use Groq API
To start using Groq with OpenAI's client libraries, pass your Groq API key to the api_key parameter and change the base_url to https://api.groq.com/openai/v1:

Python
JavaScript

import OpenAI from "openai";

const client = new OpenAI({
  apiKey: process.env.GROQ_API_KEY,
  baseURL: "https://api.groq.com/openai/v1"
});
You can find your API key here.

Currently Unsupported OpenAI Features
Note that although Groq API is mostly OpenAI compatible, there are a few features we don't support just yet:

Text Completions
The following fields are currently not supported and will result in a 400 error (yikes) if they are supplied:

logprobs

logit_bias

top_logprobs

messages[].name

If N is supplied, it must be equal to 1.

Temperature
If you set a temperature value of 0, it will be converted to 1e-8. If you run into any issues, please try setting the value to a float32 > 0 and <= 2.

Audio Transcription and Translation
The following values are not supported:

vtt
srt
Supported Models
GroqCloud currently supports the following models:


Production Models
Note: Production models are intended for use in your production environments. They meet or exceed our high standards for speed, quality, and reliability. Read more here.

MODEL ID	DEVELOPER	CONTEXT WINDOW (TOKENS)	MAX COMPLETION TOKENS	MAX FILE SIZE	DETAILS
gemma2-9b-it
Google
8,192
-
-
Details
meta-llama/llama-guard-4-12b
Meta
131,072
128
-
Details
llama-3.3-70b-versatile
Meta
128K
32,768
-
Details
llama-3.1-8b-instant
Meta
128K
8,192
-
Details
llama3-70b-8192
Meta
8,192
-
-
Details
llama3-8b-8192
Meta
8,192
-
-
Details
whisper-large-v3
OpenAI
-
-
25 MB
Details
whisper-large-v3-turbo
OpenAI
-
-
25 MB
Details
distil-whisper-large-v3-en
HuggingFace
-
-
25 MB
Details

Preview Models
Note: Preview models are intended for evaluation purposes only and should not be used in production environments as they may be discontinued at short notice. Read more about deprecations here.

MODEL ID	DEVELOPER	CONTEXT WINDOW (TOKENS)	MAX COMPLETION TOKENS	MAX FILE SIZE	DETAILS
allam-2-7b
Saudi Data and AI Authority (SDAIA)
4,096
-
-
Details
deepseek-r1-distill-llama-70b
DeepSeek
128K
-
-
Details
meta-llama/llama-4-maverick-17b-128e-instruct
Meta
131,072
8192
-
Details
meta-llama/llama-4-scout-17b-16e-instruct
Meta
131,072
8192
-
Details
meta-llama/llama-prompt-guard-2-22m
Meta
512
-
-
Details
meta-llama/llama-prompt-guard-2-86m
Meta
512
-
-
Details
mistral-saba-24b
Mistral
32K
-
-
Details
playai-tts
Playht, Inc
10K
-
Details
playai-tts-arabic
Playht, Inc
10K
-
-
Details
qwen-qwq-32b
Alibaba Cloud
128K
-
-
Details

Preview Systems
Systems are a collection of models and tools that work together to answer a user query.

Note: Preview systems are intended for evaluation purposes only and should not be used in production environments as they may be discontinued at short notice. Read more about deprecations here.

MODEL ID	DEVELOPER	CONTEXT WINDOW (TOKENS)	MAX COMPLETION TOKENS	MAX FILE SIZE	DETAILS
compound-beta
Groq
128K
8192
-
Details
compound-beta-mini
Groq
128K
8192
-
Details

Learn More About Agentic Tooling
Discover how to build powerful applications with real-time web search and code execution

Deprecated models are models that are no longer supported or will no longer be supported in the future. See our deprecation guidelines and deprecated models here.


Hosted models are directly accessible through the GroqCloud Models API endpoint using the model IDs mentioned above. You can use the https://api.groq.com/openai/v1/models endpoint to return a JSON list of all active models:

curl
JavaScript
Python

import Groq from "groq-sdk";

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

const getModels = async () => {
  return await groq.models.list();
};

getModels().then((models) => {
  // console.log(models);
});Rate Limits
Rate limits act as control measures to regulate how frequently users and applications can access our API within specified timeframes. These limits help ensure service stability, fair access, and protection against misuse so that we can serve reliable and fast inference for all.

Understanding Rate Limits
Rate limits are measured in:

RPM: Requests per minute
RPD: Requests per day
TPM: Tokens per minute
TPD: Tokens per day
ASH: Audio seconds per hour
ASD: Audio seconds per day
Rate limits apply at the organization level, not individual users. You can hit any limit type depending on which threshold you reach first.

Example: Let's say your RPM = 50 and your TPM = 200K. If you were to send 50 requests with only 100 tokens within a minute, you would reach your limit even though you did not send 200K tokens within those 50 requests.

Rate Limits
The following is a high level summary and there may be exceptions to these limits. You can view the current, exact rate limits for your organization on the limits page in your account settings.

Free Tier
Developer Tier
MODEL ID	RPM	RPD	TPM	TPD	ASH	ASD
allam-2-7b
30
7000
6000
-
-
-
compound-beta
15
200
70000
-
-
-
compound-beta-mini
15
200
70000
-
-
-
deepseek-r1-distill-llama-70b
30
1000
6000
-
-
-
distil-whisper-large-v3-en
20
2000
-
-
7200
28800
gemma2-9b-it
30
14400
15000
500000
-
-
llama-3.1-8b-instant
30
14400
6000
500000
-
-
llama-3.3-70b-versatile
30
1000
12000
100000
-
-
llama-guard-3-8b
30
14400
15000
500000
-
-
llama3-70b-8192
30
14400
6000
500000
-
-
llama3-8b-8192
30
14400
6000
500000
-
-
meta-llama/llama-4-maverick-17b-128e-instruct
30
1000
6000
-
-
-
meta-llama/llama-4-scout-17b-16e-instruct
30
1000
30000
-
-
-
meta-llama/llama-guard-4-12b
30
14400
15000
500000
-
-
meta-llama/llama-prompt-guard-2-22m
30
14400
15000
-
-
-
meta-llama/llama-prompt-guard-2-86m
30
14400
15000
-
-
-
mistral-saba-24b
30
1000
6000
500000
-
-
playai-tts
10
100
1200
3600
-
-
playai-tts-arabic
10
100
1200
3600
-
-
qwen-qwq-32b
30
1000
6000
-
-
-
whisper-large-v3
20
2000
-
-
7200
28800
whisper-large-v3-turbo
20
2000
-
-
7200
28800
Rate Limit Headers
In addition to viewing your limits on your account's limits page, you can also view rate limit information such as remaining requests and tokens in HTTP response headers as follows:

The following headers are set (values are illustrative):

Header	Value	Notes
retry-after	2	In seconds
x-ratelimit-limit-requests	14400	Always refers to Requests Per Day (RPD)
x-ratelimit-limit-tokens	18000	Always refers to Tokens Per Minute (TPM)
x-ratelimit-remaining-requests	14370	Always refers to Requests Per Day (RPD)
x-ratelimit-remaining-tokens	17997	Always refers to Tokens Per Minute (TPM)
x-ratelimit-reset-requests	2m59.56s	Always refers to Requests Per Day (RPD)
x-ratelimit-reset-tokens	7.66s	Always refers to Tokens Per Minute (TPM)
Handling Rate Limits
When you exceed rate limits, our API returns a 429 Too Many Requests HTTP status code.

Note: retry-after is only set if you hit the rate limit and status code 429 is returned. The other headers are always included.
Text Generation

Generating text with Groq's Chat Completions API enables you to have natural, conversational interactions with Groq's large language models. It processes a series of messages and generates human-like responses that can be used for various applications including conversational agents, content generation, task automation, and generating structured data outputs like JSON for your applications.

On This Page
Chat Completions
Basic Chat Completion
Streaming Chat Completion
Using Stop Sequences
JSON Mode
JSON Mode with Schema Validation
Chat Completions
Chat completions allow your applications to have dynamic interactions with Groq's models. You can send messages that include user inputs and system instructions, and receive responses that match the conversational context.


Chat models can handle both multi-turn discussions (conversations with multiple back-and-forth exchanges) and single-turn tasks where you need just one response.


For details about all available parameters, visit the API reference page.

Getting Started with Groq SDK
To start using Groq's Chat Completions API, you'll need to install the Groq SDK and set up your API key.

Python
JavaScript

npm install --save groq-sdk
Performing a Basic Chat Completion
The example below shows how to send messages to the model and receive a complete response. The messages array should include user queries and can optionally include system messages to guide the model's behavior.


import Groq from "groq-sdk";

const groq = new Groq();

export async function main() {
  const completion = await getGroqChatCompletion();
  console.log(completion.choices[0]?.message?.content || "");
}

export const getGroqChatCompletion = async () => {
  return groq.chat.completions.create({
    messages: [
      // Set an optional system message. This sets the behavior of the
      // assistant and can be used to provide specific instructions for
      // how it should behave throughout the conversation.
      {
        role: "system",
        content: "You are a helpful assistant.",
      },
      // Set a user message for the assistant to respond to.
      {
        role: "user",
        content: "Explain the importance of fast language models",
      },
    ],
    model: "llama-3.3-70b-versatile",
  });
};

main();
Streaming a Chat Completion
Streaming allows you to receive and process the model's response token by token as it's being generated. This creates a more interactive experience and can reduce perceived latency.

To stream a completion, set the parameter stream=true and process the response chunks as they arrive.


import Groq from "groq-sdk";

const groq = new Groq();

export async function main() {
  const stream = await getGroqChatStream();
  for await (const chunk of stream) {
    // Print the completion returned by the LLM.
    process.stdout.write(chunk.choices[0]?.delta?.content || "");
  }
}

export async function getGroqChatStream() {
  return groq.chat.completions.create({
    //
    // Required parameters
    //
    messages: [
      // Set an optional system message. This sets the behavior of the
      // assistant and can be used to provide specific instructions for
      // how it should behave throughout the conversation.
      {
        role: "system",
        content: "You are a helpful assistant.",
      },
      // Set a user message for the assistant to respond to.
      {
        role: "user",
        content: "Explain the importance of fast language models",
      },
    ],

    // The language model which will generate the completion.
    model: "llama-3.3-70b-versatile",

    //
    // Optional parameters
    //

    // Controls randomness: lowering results in less random completions.
    // As the temperature approaches zero, the model will become deterministic
    // and repetitive.
    temperature: 0.5,

    // The maximum number of tokens to generate. Requests can use up to
    // 2048 tokens shared between prompt and completion.
    max_completion_tokens: 1024,

    // Controls diversity via nucleus sampling: 0.5 means half of all
    // likelihood-weighted options are considered.
    top_p: 1,

    // A stop sequence is a predefined or user-specified text string that
    // signals an AI to stop generating content, ensuring its responses
    // remain focused and concise. Examples include punctuation marks and
    // markers like "[end]".
    stop: null,

    // If set, partial message deltas will be sent.
    stream: true,
  });
}

main();
Streaming a Chat Completion with a Stop Sequence
Stop sequences tell the model where to cut off its response. This feature is useful when you want to limit responses to a specific format or avoid generating content beyond a certain point.


import Groq from "groq-sdk";

const groq = new Groq();

export async function main() {
  const stream = await getGroqChatStream();
  for await (const chunk of stream) {
    // Print the completion returned by the LLM.
    process.stdout.write(chunk.choices[0]?.delta?.content || "");
  }
}

export async function getGroqChatStream() {
  return groq.chat.completions.create({
    //
    // Required parameters
    //
    messages: [
      // Set an optional system message. This sets the behavior of the
      // assistant and can be used to provide specific instructions for
      // how it should behave throughout the conversation.
      {
        role: "system",
        content: "You are a helpful assistant.",
      },
      // Set a user message for the assistant to respond to.
      {
        role: "user",
        content:
          "Start at 1 and count to 10.  Separate each number with a comma and a space",
      },
    ],

    // The language model which will generate the completion.
    model: "llama-3.3-70b-versatile",

    //
    // Optional parameters
    //

    // Controls randomness: lowering results in less random completions.
    // As the temperature approaches zero, the model will become deterministic
    // and repetitive.
    temperature: 0.5,

    // The maximum number of tokens to generate. Requests can use up to
    // 2048 tokens shared between prompt and completion.
    max_completion_tokens: 1024,

    // Controls diversity via nucleus sampling: 0.5 means half of all
    // likelihood-weighted options are considered.
    top_p: 1,

    // A stop sequence is a predefined or user-specified text string that
    // signals an AI to stop generating content, ensuring its responses
    // remain focused and concise. Examples include punctuation marks and
    // markers like "[end]".
    //
    // For this example, we will use ", 6" so that the llm stops counting at 5.
    // If multiple stop values are needed, an array of string may be passed,
    // stop: [", 6", ", six", ", Six"]
    stop: ", 6",

    // If set, partial message deltas will be sent.
    stream: true,
  });
}

main();
JSON Mode
JSON mode is a specialized feature that guarantees all chat completions will be returned as valid JSON. This is particularly useful for applications that need to parse and process structured data from model responses.


For more information on ensuring that the JSON output adheres to a specific schema, jump to: JSON Mode with Schema Validation.

How to Use JSON Mode
To use JSON mode:

Set "response_format": {"type": "json_object"} in your chat completion request
Include a description of the desired JSON structure in your system prompt
Process the returned JSON in your application
Best Practices for JSON Generation
Choose the right model: Llama performs best at generating JSON, followed by Gemma
Format preference: Request pretty-printed JSON instead of compact JSON for better readability
Keep prompts concise: Clear, direct instructions produce better JSON outputs
Provide schema examples: Include examples of the expected JSON structure in your system prompt
Limitations
JSON mode does not support streaming responses
Stop sequences cannot be used with JSON mode
If JSON generation fails, Groq will return a 400 error with code json_validate_failed
Example System Prompts
Here are practical examples showing how to structure system messages that will produce well-formed JSON:

Data Analysis API
The Data Analysis API example demonstrates how to create a system prompt that instructs the model to perform sentiment analysis on user-provided text and return the results in a structured JSON format. This pattern can be adapted for various data analysis tasks such as classification, entity extraction, or summarization.

Python
JavaScript

import { Groq } from "groq-sdk";

const groq = new Groq();

async function main() {
  const response = await groq.chat.completions.create({
    model: "llama3-8b-8192",
    messages: [
      {
        role: "system",
        content: `You are a data analysis API that performs sentiment analysis on text.
                Respond only with JSON using this format:
                {
                    "sentiment_analysis": {
                    "sentiment": "positive|negative|neutral",
                    "confidence_score": 0.95,
                    "key_phrases": [
                        {
                        "phrase": "detected key phrase",
                        "sentiment": "positive|negative|neutral"
                        }
                    ],
                    "summary": "One sentence summary of the overall sentiment"
                    }
                }`
      },
      { role: "user", content: "Analyze the sentiment of this customer review: 'I absolutely love this product! The quality exceeded my expectations, though shipping took longer than expected.'" }
    ],
    response_format: { type: "json_object" }
  });

  console.log(response.choices[0].message.content);
}

main();
These examples show how to structure system prompts to guide the model to produce well-formed JSON with your desired schema.


Sample JSON output from the sentiment analysis prompt:


{
     "sentiment_analysis": {
       "sentiment": "positive",
       "confidence_score": 0.84,
       "key_phrases": [
          {
             "phrase": "absolutely love this product",
             "sentiment": "positive"
          },
          {
             "phrase": "quality exceeded my expectations",
             "sentiment": "positive"
          }
       ],
       "summary": "The reviewer loves the product's quality, but was slightly disappointed with the shipping time."
    }
}
In this JSON response:

sentiment: Overall sentiment classification (positive, negative, or neutral)
confidence_score: A numerical value between 0 and 1 indicating the model's confidence in its sentiment classification
key_phrases: An array of important phrases extracted from the input text, each with its own sentiment classification
summary: A concise summary of the sentiment analysis capturing the main points

Using structured JSON outputs like this makes it easy for your application to programmatically parse and process the model's analysis. For more information on validating JSON outputs, see our dedicated guide on JSON Mode with Schema Validation.

Code Examples
Python
JavaScript
This JavaScript example shows how to implement JSON mode in your Node.js application. It configures a request with the JSON response format and a system prompt that guides the model to return restaurant information in a structured JSON format.


import Groq from "groq-sdk";
const groq = new Groq();

// Define the JSON schema for recipe objects
// This is the schema that the model will use to generate the JSON object, 
// which will be parsed into the Recipe class.
const schema = {
  $defs: {
    Ingredient: {
      properties: {
        name: { title: "Name", type: "string" },
        quantity: { title: "Quantity", type: "string" },
        quantity_unit: {
          anyOf: [{ type: "string" }, { type: "null" }],
          title: "Quantity Unit",
        },
      },
      required: ["name", "quantity", "quantity_unit"],
      title: "Ingredient",
      type: "object",
    },
  },
  properties: {
    recipe_name: { title: "Recipe Name", type: "string" },
    ingredients: {
      items: { $ref: "#/$defs/Ingredient" },
      title: "Ingredients",
      type: "array",
    },
    directions: {
      items: { type: "string" },
      title: "Directions",
      type: "array",
    },
  },
  required: ["recipe_name", "ingredients", "directions"],
  title: "Recipe",
  type: "object",
};

// Ingredient class representing a single recipe ingredient
class Ingredient {
  constructor(name, quantity, quantity_unit) {
    this.name = name;
    this.quantity = quantity;
    this.quantity_unit = quantity_unit || null;
  }
}

// Recipe class representing a complete recipe
class Recipe {
  constructor(recipe_name, ingredients, directions) {
    this.recipe_name = recipe_name;
    this.ingredients = ingredients;
    this.directions = directions;
  }
}

// Generates a recipe based on the recipe name
export async function getRecipe(recipe_name) {
  // Pretty printing improves completion results
  const jsonSchema = JSON.stringify(schema, null, 4);
  const chat_completion = await groq.chat.completions.create({
    messages: [
      {
        role: "system",
        content: `You are a recipe database that outputs recipes in JSON.\n'The JSON object must use the schema: ${jsonSchema}`,
      },
      {
        role: "user",
        content: `Fetch a recipe for ${recipe_name}`,
      },
    ],
    model: "llama-3.3-70b-versatile",
    temperature: 0,
    stream: false,
    response_format: { type: "json_object" },
  });

  const recipeJson = JSON.parse(chat_completion.choices[0].message.content);

  // Map the JSON ingredients to the Ingredient class
  const ingredients = recipeJson.ingredients.map((ingredient) => {
    return new Ingredient(ingredient.name, ingredient.quantity, ingredient.quantity_unit);
  });

  // Return the recipe object
  return new Recipe(recipeJson.recipe_name, ingredients, recipeJson.directions);
}

// Prints a recipe to the console with nice formatting
function printRecipe(recipe) {
  console.log("Recipe:", recipe.recipe_name);
  console.log();

  console.log("Ingredients:");
  recipe.ingredients.forEach((ingredient) => {
    console.log(
      `- ${ingredient.name}: ${ingredient.quantity} ${
        ingredient.quantity_unit || ""
      }`,
    );
  });
  console.log();

  console.log("Directions:");
  recipe.directions.forEach((direction, step) => {
    console.log(`${step + 1}. ${direction}`);
  });
}

// Main function that generates and prints a recipe
export async function main() {
  const recipe = await getRecipe("apple pie");
  printRecipe(recipe);
}

main();
JSON Mode with Schema Validation
Schema validation allows you to ensure that the response conforms to a schema, making them more reliable and easier to process programmatically.


While JSON mode ensures syntactically valid JSON, schema validation adds an additional layer of type checking and field validation to guarantee that the response not only parses as JSON but also conforms to your exact requirements.

Using Zod (or Pydantic in Python)
Zod is a TypeScript-first schema validation library that makes it easy to define and enforce schemas. In Python, Pydantic serves a similar purpose. This example demonstrates validating a product catalog entry with basic fields like name, price, and description.

Python
JavaScript
TypeScript

import { Groq } from "groq-sdk";
import { z } from "zod"; // npm install zod

const client = new Groq();

// Define a schema with Zod
const ProductSchema = z.object({
  id: z.string(),
  name: z.string(),
  price: z.number().positive(),
  description: z.string(),
  in_stock: z.boolean(),
  tags: z.array(z.string()).default([]),
});

// Create a prompt that clearly defines the expected structure
const systemPrompt = `
You are a product catalog assistant. When asked about products,
always respond with valid JSON objects that match this structure:
{
  "id": "string",
  "name": "string",
  "price": number,
  "description": "string",
  "in_stock": boolean,
  "tags": ["string"]
}
Your response should ONLY contain the JSON object and nothing else.
`;

async function getStructuredResponse() {
  try {
    // Request structured data from the model
    const completion = await client.chat.completions.create({
      model: "llama-3.3-70b-versatile",
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: "Tell me about a popular smartphone product" },
      ],
    });

    // Extract the response
    const responseContent = completion.choices[0].message.content;
    
    // Parse and validate JSON
    const jsonData = JSON.parse(responseContent || "");
    const validatedData = ProductSchema.parse(jsonData);
    
    console.log("Validation successful! Structured data:");
    console.log(JSON.stringify(validatedData, null, 2));
    
    return validatedData;
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error("Schema validation failed:", error.errors);
    } else if (error instanceof SyntaxError) {
      console.error("JSON parsing failed: The model did not return valid JSON");
    } else {
      console.error("Error:", error);
    }
  }
}

// Run the example
getStructuredResponse();
Benefits of Schema Validation
Type Checking: Ensure fields have the correct data types
Required Fields: Specify which fields must be present
Constraints: Set min/max values, length requirements, etc.
Default Values: Provide fallbacks for missing fields
Custom Validation: Add custom validation logic as needed
Using Instructor Library
The Instructor library provides a more streamlined experience by combining API calls with schema validation in a single step. This example creates a structured recipe with ingredients and cooking instructions, demonstrating automatic validation and retry logic.

Python
JavaScript
TypeScript

import { Groq } from "groq-sdk";
import Instructor from "@instructor-ai/instructor"; // npm install @instructor-ai/instructor
import { z } from "zod"; // npm install zod

// Set up the Groq client with Instructor
const client = new Groq();
const instructor = Instructor({
  client,
  mode: "TOOLS"
});

// Define your schema with Zod
const RecipeIngredientSchema = z.object({
  name: z.string(),
  quantity: z.string(),
  unit: z.string().describe("The unit of measurement, like cup, tablespoon, etc."),
});

const RecipeSchema = z.object({
  title: z.string(),
  description: z.string(),
  prep_time_minutes: z.number().int().positive(),
  cook_time_minutes: z.number().int().positive(),
  ingredients: z.array(RecipeIngredientSchema),
  instructions: z.array(z.string()).describe("Step by step cooking instructions"),
});

async function getRecipe() {
  try {
    // Request structured data with automatic validation
    const recipe = await instructor.chat.completions.create({
      model: "llama-3.3-70b-versatile",
      response_model: {
        name: "Recipe",
        schema: RecipeSchema,
      },
      messages: [
        { role: "user", content: "Give me a recipe for chocolate chip cookies" },
      ],
      max_retries: 2, // Instructor will retry if validation fails
    });

    // No need for try/catch or manual validation - instructor handles it!
    console.log(`Recipe: ${recipe.title}`);
    console.log(`Prep time: ${recipe.prep_time_minutes} minutes`);
    console.log(`Cook time: ${recipe.cook_time_minutes} minutes`);
    console.log("\nIngredients:");
    recipe.ingredients.forEach((ingredient) => {
      console.log(`- ${ingredient.quantity} ${ingredient.unit} ${ingredient.name}`);
    });
    console.log("\nInstructions:");
    recipe.instructions.forEach((step, index) => {
      console.log(`${index + 1}. ${step}`);
    });

    return recipe;
  } catch (error) {
    console.error("Error:", error);
  }
}

// Run the example
getRecipe();
Advantages of Instructor
Retry Logic: Automatically retry on validation failures
Error Messages: Detailed error messages for model feedback
Schema Extraction: The schema is translated into prompt instructions
Streamlined API: Single function call for both completion and validation
Prompt Engineering for Schema Validation
The quality of schema generation and validation depends heavily on how you formulate your system prompt. This example compares a poor prompt with a well-designed one by requesting movie information, showing how proper prompt design leads to more reliable structured data.

Python
JavaScript
TypeScript

import { Groq } from "groq-sdk";

const client = new Groq();

// Example of a poorly designed prompt
const poorPrompt = `
Give me information about a movie in JSON format.
`;

// Example of a well-designed prompt
const effectivePrompt = `
You are a movie database API. Return information about a movie with the following 
JSON structure:

{
  "title": "string",
  "year": number,
  "director": "string",
  "genre": ["string"],
  "runtime_minutes": number,
  "rating": number (1-10 scale),
  "box_office_millions": number,
  "cast": [
    {
      "actor": "string",
      "character": "string"
    }
  ]
}

The response must:
1. Include ALL fields shown above
2. Use only the exact field names shown
3. Follow the exact data types specified
4. Contain ONLY the JSON object and nothing else

IMPORTANT: Do not include any explanatory text, markdown formatting, or code blocks.
`;

// Function to run the completion and display results
async function getMovieData(prompt, title = "Example") {
  console.log(`\n--- ${title} ---`);
  
  try {
    const completion = await client.chat.completions.create({
      model: "llama-3.3-70b-versatile",
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: prompt },
        { role: "user", content: "Tell me about The Matrix" },
      ],
    });
    
    const responseContent = completion.choices[0].message.content;
    console.log("Raw response:");
    console.log(responseContent);
    
    // Try to parse as JSON
    try {
      const movieData = JSON.parse(responseContent || "");
      console.log("\nSuccessfully parsed as JSON!");
      
      // Check for expected fields
      const expectedFields = ["title", "year", "director", "genre", 
                            "runtime_minutes", "rating", "box_office_millions", "cast"];
      const missingFields = expectedFields.filter(field => !(field in movieData));
      
      if (missingFields.length > 0) {
        console.log(`Missing fields: ${missingFields.join(', ')}`);
      } else {
        console.log("All expected fields present!");
      }
      
      return movieData;
    } catch (syntaxError) {
      console.log("\nFailed to parse as JSON. Response is not valid JSON.");
      return null;
    }
  } catch (error) {
    console.error("Error:", error);
    return null;
  }
}

// Compare the results of both prompts
async function comparePrompts() {
  await getMovieData(poorPrompt, "Poor Prompt Example");
  await getMovieData(effectivePrompt, "Effective Prompt Example");
}

// Run the examples
comparePrompts();
Key Elements of Effective Prompts
Clear Role Definition: Tell the model it's an API or data service
Complete Schema Example: Show the exact structure with field names and types
Explicit Requirements: List all requirements clearly and numerically
Data Type Specifications: Indicate the expected type for each field
Format Instructions: Specify that the response should contain only JSON
Constraints: Add range or validation constraints where applicable
Working with Complex Schemas
Real-world applications often require complex, nested schemas with multiple levels of objects, arrays, and optional fields. This example creates a detailed product catalog entry with variants, reviews, and manufacturer information, demonstrating how to handle deeply nested data structures.

Python
JavaScript
TypeScript

import { Groq } from "groq-sdk";
import Instructor from "@instructor-ai/instructor"; // npm install @instructor-ai/instructor
import { z } from "zod"; // npm install zod

// Set up the client with Instructor
const groq = new Groq();
const instructor = Instructor({
  client: groq,
  mode: "TOOLS"
})

// Define a complex nested schema
const AddressSchema = z.object({
  street: z.string(),
  city: z.string(),
  state: z.string(),
  zip_code: z.string(),
  country: z.string(),
});

const ContactInfoSchema = z.object({
  email: z.string().email(),
  phone: z.string().optional(),
  address: AddressSchema,
});

const ProductVariantSchema = z.object({
  id: z.string(),
  name: z.string(),
  price: z.number().positive(),
  inventory_count: z.number().int().nonnegative(),
  attributes: z.record(z.string()),
});

const ProductReviewSchema = z.object({
  user_id: z.string(),
  rating: z.number().min(1).max(5),
  comment: z.string(),
  date: z.string(),
});

const ManufacturerSchema = z.object({
  name: z.string(),
  founded: z.string(),
  contact_info: ContactInfoSchema,
});

const ProductSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string(),
  main_category: z.string(),
  subcategories: z.array(z.string()),
  variants: z.array(ProductVariantSchema),
  reviews: z.array(ProductReviewSchema),
  average_rating: z.number().min(1).max(5),
  manufacturer: ManufacturerSchema,
});

// System prompt with clear instructions about the complex structure
const systemPrompt = `
You are a product catalog API. Generate a detailed product with ALL required fields.
Your response must be a valid JSON object matching the schema I will use to validate it.
`;

async function getComplexProduct() {
  try {
    // Use instructor to create and validate in one step
    const product = await instructor.chat.completions.create({
      model: "llama-3.3-70b-versatile",
      response_model: {
        name: "Product",
        schema: ProductSchema,
      },
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: "Give me details about a high-end camera product" },
      ],
      max_retries: 3,
    });

    // Print the validated complex object
    console.log(`Product: ${product.name}`);
    console.log(`Description: ${product.description.substring(0, 100)}...`);
    console.log(`Variants: ${product.variants.length}`);
    console.log(`Reviews: ${product.reviews.length}`);
    console.log(`Manufacturer: ${product.manufacturer.name}`);
    console.log(`\nManufacturer Contact:`);
    console.log(`  Email: ${product.manufacturer.contact_info.email}`);
    console.log(`  Address: ${product.manufacturer.contact_info.address.city}, ${product.manufacturer.contact_info.address.country}`);

    return product;
  } catch (error) {
    console.error("Error:", error);
  }
}

// Run the example
getComplexProduct();
Tips for Complex Schemas
Decompose: Break complex schemas into smaller, reusable components
Document Fields: Add descriptions to fields in your schema definition
Provide Examples: Include examples of valid objects in your prompt
Validate Incrementally: Consider validating subparts of complex responses separately
Use Types: Leverage type inference to ensure correct handling in your code
Best Practices
Schema Design
Prompt Engineering
Error Handling
Start simple and add complexity as needed.
Make fields optional when appropriate.
Provide sensible defaults for optional fields.
Use specific types and constraints rather than general ones.
Add descriptions to your schema definitions.
Was this page helpful?

Yes

No
Speech to Text
Groq API is the fastest speech-to-text solution available, offering OpenAI-compatible endpoints that enable near-instant transcriptions and translations. With Groq API, you can integrate high-quality audio processing into your applications at speeds that rival human interaction.

API Endpoints
We support two endpoints:

Endpoint	Usage	API Endpoint
Transcriptions	Convert audio to text	https://api.groq.com/openai/v1/audio/transcriptions
Translations	Translate audio to English text	https://api.groq.com/openai/v1/audio/translations
Supported Models
Model ID	Model	Supported Language(s)	Description
whisper-large-v3-turbo

Whisper Large V3 Turbo	Multilingual	A fine-tuned version of a pruned Whisper Large V3 designed for fast, multilingual transcription tasks.
distil-whisper-large-v3-en

Distil-Whisper English	English-only	A distilled, or compressed, version of OpenAI's Whisper model, designed to provide faster, lower cost English speech recognition while maintaining comparable accuracy.
whisper-large-v3

Whisper large-v3	Multilingual	Provides state-of-the-art performance with high accuracy for multilingual transcription and translation tasks.
Which Whisper Model Should You Use?
Having more choices is great, but let's try to avoid decision paralysis by breaking down the tradeoffs between models to find the one most suitable for your applications:

If your application is error-sensitive and requires multilingual support, use 
whisper-large-v3

.
If your application is less sensitive to errors and requires English only, use 
distil-whisper-large-v3-en

.
If your application requires multilingual support and you need the best price for performance, use 
whisper-large-v3-turbo

.
The following table breaks down the metrics for each model.

Model	Cost Per Hour	Language Support	Transcription Support	Translation Support	Real-time Speed Factor	Word Error Rate
whisper-large-v3

$0.111	Multilingual	Yes	Yes	189	10.3%
whisper-large-v3-turbo

$0.04	Multilingual	Yes	No	216	12%
distil-whisper-large-v3-en

$0.02	English only	Yes	No	250	13%
Working with Audio Files
Audio File Limitations
Max File Size
25 MB (free tier), 100MB (dev tier)

Max Attachment File Size
25 MB. If you need to process larger files, use the url parameter to specify a url to the file instead.

Minimum File Length
0.01 seconds

Minimum Billed Length
10 seconds. If you submit a request less than this, you will still be billed for 10 seconds.

Supported File Types
Either a URL or a direct file upload for flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm

Single Audio Track
Only the first track will be transcribed for files with multiple audio tracks. (e.g. dubbed video)

Supported Response Formats
json, verbose_json, text

Supported Timestamp Granularities
segment, word

Audio Preprocessing
Our speech-to-text models will downsample audio to 16KHz mono before transcribing, which is optimal for speech recognition. This preprocessing can be performed client-side if your original file is extremely large and you want to make it smaller without a loss in quality (without chunking, Groq API speech-to-text endpoints accept up to 25MB for free tier and 100MB for dev tier). For lower latency, convert your files to wav format. When reducing file size, we recommend FLAC for lossless compression.

The following ffmpeg command can be used to reduce file size:


ffmpeg \
  -i <your file> \
  -ar 16000 \
  -ac 1 \
  -map 0:a \
  -c:a flac \
  <output file name>.flac
Working with Larger Audio Files
For audio files that exceed our size limits or require more precise control over transcription, we recommend implementing audio chunking. This process involves:

Breaking the audio into smaller, overlapping segments
Processing each segment independently
Combining the results while handling overlapping
To learn more about this process and get code for your own implementation, see the complete audio chunking tutorial in our Groq API Cookbook. 

Using the API
The following are request parameters you can use in your transcription and translation requests:

Parameter	Type	Default	Description
file	string	Required unless using url instead	The audio file object for direct upload to translate/transcribe.
url	string	Required unless using file instead	The audio URL to translate/transcribe (supports Base64URL).
language	string	Optional	The language of the input audio. Supplying the input language in ISO-639-1 (i.e. en, tr`) format will improve accuracy and latency.

The translations endpoint only supports 'en' as a parameter option.
model	string	Required	ID of the model to use.
prompt	string	Optional	Prompt to guide the model's style or specify how to spell unfamiliar words. (limited to 224 tokens)
response_format	string	json	Define the output response format.

Set to verbose_json to receive timestamps for audio segments.

Set to text to return a text response.
temperature	float	0	The temperature between 0 and 1. For translations and transcriptions, we recommend the default value of 0.
timestamp_granularities[]	array	segment	The timestamp granularities to populate for this transcription. response_format must be set verbose_json to use timestamp granularities.

Either or both of word and segment are supported.

segment returns full metadata and word returns only word, start, and end timestamps. To get both word-level timestamps and full segment metadata, include both values in the array.
Example Usage of Transcription Endpoint
The transcription endpoint allows you to transcribe spoken words in audio or video files.

Python
JavaScript
curl
The Groq SDK package can be installed using the following command:


npm install --save groq-sdk
The following code snippet demonstrates how to use Groq API to transcribe an audio file in JavaScript:


import fs from "fs";
import Groq from "groq-sdk";

// Initialize the Groq client
const groq = new Groq();

async function main() {
  // Create a transcription job
  const transcription = await groq.audio.transcriptions.create({
    file: fs.createReadStream("YOUR_AUDIO.wav"), // Required path to audio file - replace with your audio file!
    model: "whisper-large-v3-turbo", // Required model to use for transcription
    prompt: "Specify context or spelling", // Optional
    response_format: "verbose_json", // Optional
    timestamp_granularities: ["word", "segment"], // Optional (must set response_format to "json" to use and can specify "word", "segment" (default), or both)
    language: "en", // Optional
    temperature: 0.0, // Optional
  });
  // To print only the transcription text, you'd use console.log(transcription.text); (here we're printing the entire transcription object to access timestamps)
  console.log(JSON.stringify(transcription, null, 2));
}
main();
Example Usage of Translation Endpoint
The translation endpoint allows you to translate spoken words in audio or video files to English.

Python
JavaScript
curl
The Groq SDK package can be installed using the following command:


npm install --save groq-sdk
The following code snippet demonstrates how to use Groq API to translate an audio file in JavaScript:


import fs from "fs";
import Groq from "groq-sdk";

// Initialize the Groq client
const groq = new Groq();
async function main() {
  // Create a translation job
  const translation = await groq.audio.translations.create({
    file: fs.createReadStream("sample_audio.m4a"), // Required path to audio file - replace with your audio file!
    model: "whisper-large-v3", // Required model to use for translation
    prompt: "Specify context or spelling", // Optional
    language: "en", // Optional ('en' only)
    response_format: "json", // Optional
    temperature: 0.0, // Optional
  });
  // Log the transcribed text
  console.log(translation.text);
}
main();
Understanding Metadata Fields
When working with Groq API, setting response_format to verbose_json outputs each segment of transcribed text with valuable metadata that helps us understand the quality and characteristics of our transcription, including avg_logprob, compression_ratio, and no_speech_prob.

This information can help us with debugging any transcription issues. Let's examine what this metadata tells us using a real example:


{
  "id": 8,
  "seek": 3000,
  "start": 43.92,
  "end": 50.16,
  "text": " document that the functional specification that you started to read through that isn't just the",
  "tokens": [51061, 4166, 300, 264, 11745, 31256],
  "temperature": 0,
  "avg_logprob": -0.097569615,
  "compression_ratio": 1.6637554,
  "no_speech_prob": 0.012814695
}
As shown in the above example, we receive timing information as well as quality indicators. Let's gain a better understanding of what each field means:

id:8: The 9th segment in the transcription (counting begins at 0)
seek: Indicates where in the audio file this segment begins (3000 in this case)
start and end timestamps: Tell us exactly when this segment occurs in the audio (43.92 to 50.16 seconds in our example)
avg_logprob (Average Log Probability): -0.097569615 in our example indicates very high confidence. Values closer to 0 suggest better confidence, while more negative values (like -0.5 or lower) might indicate transcription issues.
no_speech_prob (No Speech Probability): 0.0.012814695 is very low, suggesting this is definitely speech. Higher values (closer to 1) would indicate potential silence or non-speech audio.
compression_ratio: 1.6637554 is a healthy value, indicating normal speech patterns. Unusual values (very high or low) might suggest issues with speech clarity or word boundaries.
Using Metadata for Debugging
When troubleshooting transcription issues, look for these patterns:

Low Confidence Sections: If avg_logprob drops significantly (becomes more negative), check for background noise, multiple speakers talking simultaneously, unclear pronunciation, and strong accents. Consider cleaning up the audio in these sections or adjusting chunk sizes around problematic chunk boundaries.
Non-Speech Detection: High no_speech_prob values might indicate silence periods that could be trimmed, background music or noise, or non-verbal sounds being misinterpreted as speech. Consider noise reduction when preprocessing.
Unusual Speech Patterns: Unexpected compression_ratio values can reveal stuttering or word repetition, speaker talking unusually fast or slow, or audio quality issues affecting word separation.
Quality Thresholds and Regular Monitoring
We recommend setting acceptable ranges for each metadata value we reviewed above and flagging segments that fall outside these ranges to be able to identify and adjust preprocessing or chunking strategies for flagged sections.

By understanding and monitoring these metadata values, you can significantly improve your transcription quality and quickly identify potential issues in your audio processing pipeline.

Prompting Guidelines
The prompt parameter (max 224 tokens) helps provide context and maintain a consistent output style. Unlike chat completion prompts, these prompts only guide style and context, not specific actions.

Best Practices
Provide relevant context about the audio content, such as the type of conversation, topic, or speakers involved.
Use the same language as the language of the audio file.
Steer the model's output by denoting proper spellings or emulate a specific writing style or tone.
Keep the prompt concise and focused on stylistic guidance.
We can't wait to see what you build! 🚀

Was this page helpful?

Yes

No  
Text to Speech
Learn how to instantly generate lifelike audio from text.

Overview
The Groq API speech endpoint provides fast text-to-speech (TTS), enabling you to convert text to spoken audio in seconds with our available TTS models.

With support for 23 voices, 19 in English and 4 in Arabic, you can instantly create life-like audio content for customer support agents, characters for game development, and more.

API Endpoint
Endpoint	Usage	API Endpoint
Speech	Convert text to audio	https://api.groq.com/openai/v1/audio/speech
Supported Models
Model ID	Model Card	Supported Language(s)	Description
playai-tts	Card 	English	High-quality TTS model for English speech generation.
playai-tts-arabic	Card 	Arabic	High-quality TTS model for Arabic speech generation.
Working with Speech
Quick Start
The speech endpoint takes four key inputs:

model: playai-tts or playai-tts-arabic
input: the text to generate audio from
voice: the desired voice for output
response format: defaults to "wav"
Python
JavaScript
curl
The Groq SDK package can be installed using the following command:


npm install --save groq-sdk
The following is an example of a request using playai-tts. To use the Arabic model, use the playai-tts-arabic model ID and an Arabic prompt:


import fs from "fs";
import path from "path";
import Groq from 'groq-sdk';

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY
});

const speechFilePath = "speech.wav";
const model = "playai-tts";
const voice = "Fritz-PlayAI";
const text = "I love building and shipping new features for our users!";
const responseFormat = "wav";

async function main() {
  const response = await groq.audio.speech.create({
    model: model,
    voice: voice,
    input: text,
    response_format: responseFormat
  });
  
  const buffer = Buffer.from(await response.arrayBuffer());
  await fs.promises.writeFile(speechFilePath, buffer);
}

main();
Parameters
Parameter	Type	Required	Value	Description
model	string	Yes	playai-tts
playai-tts-arabic	Model ID to use for TTS.
input	string	Yes	-	User input text to be converted to speech. Maximum length is 10K characters.
voice	string	Yes	See available English and Arabic voices.	The voice to use for audio generation. There are currently 26 English options for playai-tts and 4 Arabic options for playai-tts-arabic.
response_format	string	Optional	"wav"	Format of the response audio file. Defaults to currently supported "wav".
Available English Voices
The playai-tts model currently supports 19 English voices that you can pass into the voice parameter (Arista-PlayAI, Atlas-PlayAI, Basil-PlayAI, Briggs-PlayAI, Calum-PlayAI, Celeste-PlayAI, Cheyenne-PlayAI, Chip-PlayAI, Cillian-PlayAI, Deedee-PlayAI, Fritz-PlayAI, Gail-PlayAI, Indigo-PlayAI, Mamaw-PlayAI, Mason-PlayAI, Mikail-PlayAI, Mitch-PlayAI, Quinn-PlayAI, Thunder-PlayAI).

Experiment to find the voice you need for your application:

Arista-PlayAI


0:00
0:03

Atlas-PlayAI


0:00
0:04

Basil-PlayAI


0:00
0:03

Briggs-PlayAI


0:00
0:03

Calum-PlayAI


0:00
0:03

Celeste-PlayAI


0:00
0:03

Cheyenne-PlayAI


0:00
0:03

Chip-PlayAI


0:00
0:03

Cillian-PlayAI


0:00
0:02

Deedee-PlayAI


0:00
0:04

Fritz-PlayAI


0:00
0:03

Gail-PlayAI


0:00
0:03

Indigo-PlayAI


0:00
0:03

Mamaw-PlayAI


0:00
0:03

Mason-PlayAI


0:00
0:03

Mikail-PlayAI


0:00
0:03

Mitch-PlayAI


0:00
0:03

Quinn-PlayAI


0:00
0:03

Thunder-PlayAI


0:00
0:03

Available Arabic Voices
The playai-tts-arabic model currently supports 4 Arabic voices that you can pass into the voice parameter (Ahmad-PlayAI, Amira-PlayAI, Khalid-PlayAI, Nasser-PlayAI).

Experiment to find the voice you need for your application:

Ahmad-PlayAI


0:00
0:03

Amira-PlayAI


0:00
0:03

Khalid-PlayAI


0:00
0:02

Nasser-PlayAI


0:00
0:03

Was this page helpful?

Yes

No