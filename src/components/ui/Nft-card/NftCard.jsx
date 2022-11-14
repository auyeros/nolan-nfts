import React, { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import "./nft-card.module.css";

import Modal from "../Modal/Modal";

const NftCard = (props) => {
  const { title, id, currentBid, creatorImg, imgUrl, creator } = props.item;

  const [showModal, setShowModal] = useState(false);

  return (
    <div className="single__nft__card">
      <div className="nft__img">
        <Image src={imgUrl} alt="" className="w-100" />
      </div>

      <div className="nft__content">
        <h5 className="nft__title">
          <Link
            href={{ pathname: '/market/[id]', query: { id: id }, }}>{title}</Link>
        </h5>

        <div className="creator__info-wrapper d-flex gap-3">

          <div className="creator__info w-100 d-flex align-items-center justify-content-between">


            <div>
              <h6>Current Bid</h6>
              <p>{currentBid} ETH</p>
              <p>{currentBid} EUR</p>
            </div>
          </div>
        </div>

        <div className=" mt-3 d-flex align-items-center justify-content-between">
          <button
            className="bid__btn d-flex align-items-center gap-1"
            onClick={() => setShowModal(true)}
          >
            <i className="ri-shopping-bag-line"></i> Place Bid
          </button>
          <button
            className="bid__btn d-flex align-items-center gap-1"

          >
            <i className="ri-shopping-bag-line"></i> Buy now
          </button>

          {showModal && <Modal setShowModal={setShowModal} />}
        </div>
      </div>
    </div>
  );
};

export default NftCard;
