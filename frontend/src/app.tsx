import React from "react";

export const App = () => {
  const [response, setResponse] = React.useState<null | string>();
  const fetchFromBackend = async () => {
    const response = await fetch("/api");
    setResponse(await response.text());
  };
  if (response == null) {
    return <button onClick={fetchFromBackend}>fetch date and time from backend</button>;
  }
  return <div>Response from backend: {response}</div>;
};
