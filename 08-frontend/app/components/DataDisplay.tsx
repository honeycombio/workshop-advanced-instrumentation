'use client';

import { useEffect, useState } from 'react';

const host = process.env.NEXT_PUBLIC_HOST || "localhost";

interface DataDisplayProps {
  type: 'year' | 'name';
  initialData: any;
}

async function fetchData(type: string) {
  try {
    const response = await fetch(`http://${host}:6003/api/${type}`, {
      cache: "no-store",
    });

    if (!response.ok) {
      throw new Error(`Error: ${response.statusText}`);
    }

    return response.json();
  } catch (error) {
    return { error: "Failed to fetch data" };
  }
}

export default function DataDisplay({ type, initialData }: DataDisplayProps) {
  const [data, setData] = useState(initialData);
  const [isLoading, setIsLoading] = useState(false);

  const refreshData = async () => {
    setIsLoading(true);
    const newData = await fetchData(type);
    setData(newData);
    setIsLoading(false);
  };

  useEffect(() => {
    const element = document.getElementById(`${type}-data`);
    if (element) {
      element.textContent = isLoading 
        ? "Loading..." 
        : JSON.stringify(data, null, 2);
    }
  }, [data, isLoading, type]);

  return (
    <div className="flex flex-col gap-4">
      <h2 className="text-2xl font-bold">
        → {type === 'year' ? '📅 Year' : '🏷️ Name'} Service
      </h2>
      <pre className="text-sm" id={`${type}-data`}>
        {"error" in data
          ? <p style={{ color: "red" }}>❌ {data.error}</p>
          : JSON.stringify(data, null, 2)}
      </pre>
      <button 
        onClick={refreshData}
        disabled={isLoading}
        className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:opacity-50"
      >
        {isLoading ? 'Refreshing...' : `Refresh ${type} Data`}
      </button>
    </div>
  );
} 