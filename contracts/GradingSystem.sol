// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import {FHE} from "@fhevm/solidity/lib/FHE.sol";
import {euint32} from "@fhevm/solidity/lib/FHE.sol";

// grading system with encrypted scores
contract GradingSystem is ZamaEthereumConfig {
    using FHE for euint32;
    
    struct Grade {
        address student;
        uint256 courseId;
        euint32 score;      // encrypted grade (0-100)
        address instructor;
        uint256 gradedAt;
    }
    
    struct CourseGrade {
        euint32 average;    // encrypted average
        uint256 gradeCount;
    }
    
    mapping(address => mapping(uint256 => Grade)) public grades;
    mapping(uint256 => CourseGrade) public courseAverages;
    
    event GradeRecorded(address indexed student, uint256 courseId);
    
    function recordGrade(
        address student,
        uint256 courseId,
        euint32 encryptedScore
    ) external {
        grades[student][courseId] = Grade({
            student: student,
            courseId: courseId,
            score: encryptedScore,
            instructor: msg.sender,
            gradedAt: block.timestamp
        });
        
        // update course average (simplified)
        CourseGrade storage courseGrade = courseAverages[courseId];
        courseGrade.average = courseGrade.average.add(encryptedScore);
        courseGrade.gradeCount++;
        
        emit GradeRecorded(student, courseId);
    }
    
    function getGrade(address student, uint256 courseId) external view returns (euint32) {
        return grades[student][courseId].score;
    }
}

