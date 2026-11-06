// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ZombieFactory {
    // Анкета зомби: кличка, ДНК и время создания
    struct Zombie {
        string name;
        uint256 dna;
        uint256 createdAt;
    }

    // Макс значение, чтобы число не было огромным
    uint256 public constant DNA_MODULUS = 10 ** 16;

    Zombie[] private zombies;
    mapping(uint256 => address) public zombieToOwner; // ID зомби - адрес его владельца
    mapping(address => uint256) public ownerZombieCount; // Счетчик для имеющихся у владельца зомби (не более 1)

    event ZombieCreated(uint256 indexed id, address indexed owner, string name, uint256 dna);

    function createZombie(string calldata name) external returns (uint256 id) {
        require(bytes(name).length > 0, "Empty name");
        require(ownerZombieCount[msg.sender] == 0, "Already has zombie");

        // ID - кол-во зомби в массиве на данный момент (первый зомби 0, следующий 1 и тд)
        id = zombies.length;
        // ДНК - склейка адреса и имени, перемешанные хешем (подогнаны под заданный диапазон)
        uint256 dna = uint256(keccak256(abi.encodePacked(msg.sender, name))) % DNA_MODULUS;

        zombies.push(Zombie({
            name: name,
            dna: dna,
            createdAt: block.timestamp
        }));

        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;

        emit ZombieCreated(id, msg.sender, name, dna);
    }

    function totalZombies() external view returns (uint256) {
        return zombies.length;
    }

    function getZombie(uint256 id) external view returns (string memory, uint256, uint256) {
        Zombie memory z = zombies[id];
        return (z.name, z.dna, z.createdAt);
    }
}