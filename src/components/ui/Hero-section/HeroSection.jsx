import React from "react";
import { Container, Row, Col } from "reactstrap";

import "./hero-section.module.css";


const HeroSection = () => {
  return (
    <section className="hero__section">
      <Container>

        <Row>
          <Col lg="6" md="6">
            <div className="hero__content">
              <h2>
                BUILDING UNIQUE SOLUTIONS TO IMPROVE THE HISTORY OF OWNERSHIP
                <span>AND REDEFINE</span> THE SECONDARY MARKET FOR LUXURY ITEMS
              </h2>
              <p>
                GET TO THE SOURCE
              </p>
            </div>
          </Col>

          <Col lg="6" md="6">

          </Col>
        </Row>
      </Container>
    </section>
  );
};

export default HeroSection;
