"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.habitSuggestionFlow = void 0;
var index_1 = require("./index"); // Import the configured Genkit instance
// import { z } from 'zod'; // Remove Zod import for now
// Define a flow for generating habit suggestions
exports.habitSuggestionFlow = index_1.ai.defineFlow(// Use the imported 'ai' instance
'habitSuggestionFlow', // Flow name as the first argument
function (userInfo) { return __awaiter(void 0, void 0, void 0, function () {
    var promptText, aiResponse, responseJson;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                promptText = "Generate personalized habit suggestions based on the following user information: \n    ".concat(JSON.stringify(userInfo, null, 2), "\n    \n    Provide 5 specific habit suggestions that are:\n    1. Realistic and achievable\n    2. Aligned with the user's goals and preferences\n    3. Specific enough to be actionable\n    4. Varied in terms of difficulty and time commitment\n    \n    For each habit suggestion, include:\n    - A clear title for the habit\n    - A brief description of the habit\n    - Frequency recommendation (daily, weekly, etc.)\n    - Estimated time commitment\n    - Expected benefits\n    - Tips for successful implementation\n    \n    Format your response as a JSON object with an array of habit suggestions.");
                return [4 /*yield*/, index_1.ai.generate({
                        prompt: promptText,
                        config: {
                            responseMimeType: 'application/json', // Request JSON output
                        },
                    })];
            case 1:
                aiResponse = _a.sent();
                try {
                    responseJson = JSON.parse(aiResponse.text);
                    return [2 /*return*/, {
                            suggestions: responseJson.habits || responseJson,
                            timestamp: new Date().toISOString(),
                            userInfo: userInfo
                        }];
                }
                catch (error) {
                    console.error('Error parsing AI response:', error);
                    // Fallback response if parsing fails
                    return [2 /*return*/, {
                            suggestions: [
                                {
                                    title: "Morning Walk",
                                    description: "Start your day with a 15-minute walk to boost energy and mood",
                                    frequency: "Daily",
                                    timeCommitment: "15 minutes",
                                    benefits: "Improved mood, energy, and metabolism",
                                    tips: "Prepare your walking shoes the night before"
                                }
                            ],
                            timestamp: new Date().toISOString(),
                            userInfo: userInfo,
                            error: "Error parsing AI response, showing default suggestion"
                        }];
                }
                return [2 /*return*/];
        }
    });
}); });
// Only run this when executing the file directly, not when importing
if (require.main === module) {
    var sampleUserInfo = {
        goals: ["Improve fitness", "Reduce stress"],
        preferences: ["Morning activities", "Outdoor activities"],
        challenges: ["Limited time", "Low motivation"],
        currentRoutine: {
            wakeUpTime: "7:00 AM",
            bedTime: "11:00 PM",
            workHours: "9:00 AM - 5:00 PM"
        }
    };
    (0, exports.habitSuggestionFlow)(sampleUserInfo).then(function (result) {
        console.log(JSON.stringify(result, null, 2));
    });
}
