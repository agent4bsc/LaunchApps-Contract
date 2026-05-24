// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*

AI AGENT IDENTITY ERC8004
BSC MAINNET

*/

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Agent4IdentityERC8004 is ERC721URIStorage, Ownable {

    using Strings for uint256;

    uint256 public nextId = 1;

    struct Identity {

        string uniqueId;
        address owner;
        string image;
        string agentName;

    }

    mapping(uint256 => Identity) public identities;

    mapping(string => bool) public usedIds;

    event IdentityCreated(

        uint256 indexed tokenId,
        address indexed owner,
        string uniqueId,
        string agentName

    );

    constructor()
        ERC721("Agent4 AI Identity", "A4AI")
        Ownable(msg.sender)
    {}

    function createIdentity(

        string memory agentName,
        string memory imageURI

    ) external returns (uint256) {

        uint256 tokenId = nextId;

        string memory uniqueCode =
            generateUniqueCode(
                msg.sender,
                tokenId
            );

        usedIds[uniqueCode] = true;

        identities[tokenId] = Identity({

            uniqueId: uniqueCode,
            owner: msg.sender,
            image: imageURI,
            agentName: agentName

        });

        _safeMint(msg.sender, tokenId);

        string memory metadata =
            buildMetadata(

                tokenId,
                agentName,
                imageURI,
                uniqueCode

            );

        _setTokenURI(tokenId, metadata);

        emit IdentityCreated(

            tokenId,
            msg.sender,
            uniqueCode,
            agentName

        );

        nextId++;

        return tokenId;
    }

    function generateUniqueCode(

        address user,
        uint256 tokenId

    ) internal view returns (string memory) {

        bytes memory chars =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

        bytes memory result = new bytes(6);

        uint256 random =
            uint256(

                keccak256(

                    abi.encodePacked(

                        block.timestamp,
                        user,
                        tokenId,
                        block.prevrandao

                    )

                )

            );

        for (uint256 i = 0; i < 6; i++) {

            result[i] =
                chars[random % chars.length];

            random /= chars.length;
        }

        return string(result);
    }

    function buildMetadata(

        uint256 tokenId,
        string memory agentName,
        string memory imageURI,
        string memory uniqueCode

    ) internal pure returns (string memory) {

        bytes memory dataURI = abi.encodePacked(

            "{",

                '"name":"', agentName, '",',

                '"description":"AI Agent Identity ERC8004",',

                '"image":"', imageURI, '",',

                '"attributes":[',

                    '{',

                        '"trait_type":"Identity Code",',
                        '"value":"', uniqueCode, '"'

                    '},',

                    '{',

                        '"trait_type":"Standard",',
                        '"value":"ERC8004"'

                    '},',

                    '{',

                        '"trait_type":"Token ID",',
                        '"value":"', tokenId.toString(), '"'

                    '}',

                "]",

            "}"

        );

        return string(

            abi.encodePacked(

                "data:application/json;base64,",
                Base64.encode(dataURI)

            )

        );
    }

    function getIdentity(
        uint256 tokenId
    )
        external
        view
        returns (

            string memory uniqueId,
            address ownerAddress,
            string memory image,
            string memory name

        )
    {

        Identity memory id =
            identities[tokenId];

        return (

            id.uniqueId,
            id.owner,
            id.image,
            id.agentName

        );
    }

}
