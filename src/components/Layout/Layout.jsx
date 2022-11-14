import React from "react";
import Routers from "../../routes/Routers";
import Header from "../Header/Header";
const Layout = () => {
  return (
    <div>
      <Header />
      <div>
        <Routers />
      </div>
    </div>
  );
};

export default Layout;
