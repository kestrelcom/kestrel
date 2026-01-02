import { useState } from "react";
import "./App.css";

function App() {
  const [message, setMessage] = useState("");

  return (
    <div className="container">
      <h1>Kestrel</h1>
      <p>{message}</p>
    </div>
  );
}

export default App;

