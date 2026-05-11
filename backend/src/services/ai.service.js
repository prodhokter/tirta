const OpenAI = require('openai');
const logger = require('../utils/logger');

const SYSTEM_PROMPT = `Kamu adalah TIRTA Assistant, asisten kesehatan virtual yang HANYA membahas topik seputar Tuberkulosis (TBC/TB) dan kesehatan paru-paru.

Aturan WAJIB:
1. Hanya jawab pertanyaan tentang TBC, kesehatan paru, dan topik terkait
2. Jika ditanya topik di luar TBC, tolak dengan sopan dan arahkan kembali ke topik TBC
3. Gunakan Bahasa Indonesia yang ramah, mudah dipahami masyarakat awam
4. Selalu tambahkan disclaimer bahwa kamu bukan pengganti dokter
5. Jika pertanyaan darurat medis, arahkan ke fasilitas kesehatan terdekat
6. Jangan berikan dosis obat spesifik — arahkan ke dokter atau apoteker

Gaya komunikasi:
- Hangat dan empatik
- Bahasa sederhana, hindari jargon medis berlebihan
- Singkat namun informatif (maks 200 kata per respons)`;

let client = null;

function getClient() {
  if (!client) {
    const apiKey = process.env.AI_API_KEY;
    if (!apiKey) {
      throw new Error('AI_API_KEY environment variable is not set');
    }
    client = new OpenAI({
      apiKey,
      baseURL: process.env.AI_BASE_URL || 'https://api.deepseek.com',
    });
  }
  return client;
}

async function chat(messages) {
  const openai = getClient();
  const model = process.env.AI_MODEL || 'deepseek-v4-flash';

  logger.debug(`AI chat request: model=${model}, messages=${messages.length}`);

  const response = await openai.chat.completions.create({
    model,
    max_tokens: 500,
    messages: [
      { role: 'system', content: SYSTEM_PROMPT },
      ...messages,
    ],
  });

  const responseText = response.choices[0]?.message?.content || '';

  logger.debug(`AI chat response: ${responseText.substring(0, 100)}...`);

  return responseText;
}

/**
 * Streaming chat — returns an async iterable of content chunks.
 */
async function* chatStream(messages) {
  const openai = getClient();
  const model = process.env.AI_MODEL || 'deepseek-v4-flash';

  logger.debug(`AI stream request: model=${model}, messages=${messages.length}`);

  const stream = await openai.chat.completions.create({
    model,
    max_tokens: 500,
    stream: true,
    messages: [
      { role: 'system', content: SYSTEM_PROMPT },
      ...messages,
    ],
  });

  for await (const chunk of stream) {
    const content = chunk.choices[0]?.delta?.content;
    if (content) {
      yield content;
    }
  }

  logger.debug('AI stream completed');
}

module.exports = { chat, chatStream };
