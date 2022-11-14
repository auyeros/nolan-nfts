import React, { useState } from "react";



import { NFT__DATA } from "../../assets/data/data";

import { Container, Row, Col } from "reactstrap";

import styles from "../../styles/market.module.css";

import CommonSection from "../../components/ui/Common-section/CommonSection";
import NftCard from "../../components/ui/Nft-card/NftCard";


const Market = () => {
  const [data, setData] = useState(NFT__DATA);


  // ====== SORTING DATA BY HIGH, MID, LOW RATE =========
  const handleSort = (e) => {
    const filterValue = e.target.value;

    if (filterValue === "high") {
      const filterData = NFT__DATA.filter((item) => item.currentBid >= 6);

      setData(filterData);
    }

    if (filterValue === "mid") {
      const filterData = NFT__DATA.filter(
        (item) => item.currentBid >= 5.5 && item.currentBid < 6
      );

      setData(filterData);
    }

    if (filterValue === "low") {
      const filterData = NFT__DATA.filter(
        (item) => item.currentBid >= 4.89 && item.currentBid < 5.5
      );

      setData(filterData);
    }
  };

  return (
    <>
      <CommonSection title={"MarketPlace"} />

      <section>
        <Container>
          <Col lg="12" className="mb-5">
            <div className="d-flex align-items-center justify-content-between" {...styles.market__product__filter}>
              <div className="d-flex align-items-center gap-5" {...styles.filter__left}>


                <div className={styles.filter__right}>
                  <select onChange={handleSort}>
                    <option>Sort By</option>
                    <option value="high">Noir</option>
                    <option value="mid">Aged Merlot</option>
                    <option value="low">Cabernet Sauvignon</option>
                  </select>
                </div>
              </div>
            </div>
          </Col>
          <Row>


            {data?.map((item) => (
              <Col lg="3" md="4" sm="6" className="mb-4" key={item.id}>
                <NftCard item={item} />
              </Col>
            ))}
          </Row>
        </Container>
      </section>
    </>
  );
};

export default Market;
