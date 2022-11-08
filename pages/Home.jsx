import React from "react";
import styles from "./styles/HomePage.module.css";
const Home = () => {
  return (
    <div className={styles.homeDiv}>
      <div className={styles.navbar}>
        <ul>
          <li>
            <a href="">Social</a>
          </li>
          <li>
            <a href="">Contact</a>
          </li>
        </ul>
      </div>
      <div className={styles.main}>
        <h1>verita</h1>
        <div className={styles.submain}>
          <h2>
            Building unique solutions to improve the history of ownership and
            redefine the secondary market for luxury items
          </h2>
        </div>
      </div>
    </div>
  );
};

export default Home;
