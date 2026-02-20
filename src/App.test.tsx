import { render, screen } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import { describe, expect, it } from "vitest";
import { App } from "./App";

describe("App", () => {
  it("renders the starter home page", () => {
    render(
      <BrowserRouter>
        <App />
      </BrowserRouter>,
    );

    expect(screen.getByRole("heading", { name: "Web App Starter" })).toBeInTheDocument();
    expect(screen.getByRole("heading", { name: "Welcome" })).toBeInTheDocument();
  });
});
