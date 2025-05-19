"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ai = void 0;
var genkit_1 = require("genkit");
var googleai_1 = require("@genkit-ai/googleai");
var firebase_1 = require("@genkit-ai/firebase"); // Import Firebase Telemetry
// Configure a single Genkit instance for the project
exports.ai = (0, genkit_1.genkit)({
    plugins: [
        (0, googleai_1.googleAI)({ apiKey: 'AIzaSyBMcwWGph2pJgdaI2naOlYbbWIQpyu79kw' }), // Usando a chave de API do AI Studio diretamente
    ],
    model: googleai_1.gemini15Flash, // set default model for the project
});
(0, firebase_1.enableFirebaseTelemetry)(); // Enable Firebase Telemetry
// Export the defined flows
__exportStar(require("./helloFlow"), exports);
__exportStar(require("./onboardingFlows"), exports);
__exportStar(require("./habitSuggestionFlows"), exports);
