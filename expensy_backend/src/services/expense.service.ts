import redis from '../config/redis';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, ScanCommand, PutCommand } from '@aws-sdk/lib-dynamodb';
import { v4 as uuidv4 } from 'uuid';

const client = new DynamoDBClient({ region: process.env.AWS_REGION || 'us-east-1' });
const docClient = DynamoDBDocumentClient.from(client);
const tableName = process.env.DYNAMODB_TABLE_NAME || 'expensy-expenses-alain';

export class ExpenseService {
  async getAllExpenses() {
    // 1. Vérification du cache Redis
    try {
      const cachedExpenses = await redis.get('expenses');
      if (cachedExpenses) {
        console.log('Cache hit');
        return JSON.parse(cachedExpenses);
      }
    } catch (redisError) {
      console.warn('Redis read error, fallbacking to DynamoDB:', redisError);
    }

    // 2. Lecture dans DynamoDB
    console.log('Cache miss - Fetching from DynamoDB');
    const command = new ScanCommand({
      TableName: tableName,
    });

    const response = await docClient.send(command);
    const expenses = response.Items || [];

    // 3. Mise en cache Redis (expiration 5 minutes)
    try {
      await redis.set('expenses', JSON.stringify(expenses), 'EX', 60 * 5);
    } catch (redisError) {
      console.warn('Redis write error:', redisError);
    }

    return expenses;
  }

  async createExpense(expense: { name: string; amount: number; category: string }) {
    // Génération d'un ID unique et horodatage pour DynamoDB
    const newExpense = {
      id: uuidv4(),
      ...expense,
      createdAt: new Date().toISOString(),
    };

    // 1. Écriture dans DynamoDB
    const command = new PutCommand({
      TableName: tableName,
      Item: newExpense,
    });

    await docClient.send(command);

    // 2. Invalidation du cache Redis
    try {
      await redis.del('expenses');
      console.log('Cache invalidated');
    } catch (redisError) {
      console.warn('Redis cache invalidation error:', redisError);
    }

    return newExpense;
  }
}