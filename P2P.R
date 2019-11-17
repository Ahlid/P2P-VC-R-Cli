# Title     : P2P Network
# Objective : Manage the network using a raft approach with market as a voter
# Created by: Tiago
# Created on: 12/11/2019

.p2p <- new.env()

.p2p.LEADER = 'LEADER'
.p2p.CANDIDATE = 'CANDIDATE'
.p2p.FOLLOWER = 'FOLLOWER'

.p2p.id <- NULL;
.p2p.group_id <- NULL;
.p2p.group_volunteers <- NULL;
.p2p.votedFor <- NULL;
.p2p.leaderId <- NULL;
.p2p.status <- .p2p.FOLLOWER;
.p2p.currentTerm <- 0;
.p2p.timeout <- 1000;
.p2p.tclTaskScheduleId <- 'RAFT';


startRaft <- function(id, group_id, group_volunteers){
    .p2p.id <- id
    .p2p.group_id <- group_id
    .p2p.group_volunteers <- group_volunteers
    tclTaskSchedule(.p2p.timeout, onRaftTimeout(), id = .p2p.tclTaskScheduleId, redo = FALSE)
}

sendAppendRPC <- function(){
    #todo implement
}

onLeaderAppendRPC <- function(leaderId, group_id, currentTerm){
    .p2p.votedFor = NULL
    .p2p.status = .p2p.FOLLOWER
    # todo clear leader timeout
    if(leaderId == .p2p.leaderId && group_id == .p2p.group_id && currentTerm >= .p2p.currentTerm){
        tclTaskChange(.p2p.tclTaskScheduleId, onRaftTimeout(), .p2p.timeout, redo = FALSE)
        .p2p.currentTerm = currentTerm
    } else if(leaderId != .p2p.leaderId && group_id == .p2p.group_id && currentTerm >= .p2p.currentTerm){
        tclTaskChange(.p2p.tclTaskScheduleId, onRaftTimeout(), .p2p.timeout, redo = FALSE)
        .p2p.leaderId = leaderId
        .p2p.currentTerm = currentTerm
    }
}

onRaftTimeout <- function(){
    .p2p.status = .p2p.CANDIDATE
    .p2p.currentTerm = .p2p.currentTerm + 1;
    .p2p.votedFor <- .p2p.id;
    tclTaskSchedule(.p2p.timeout, onRaftTimeout(), id = .p2p.tclTaskScheduleId, redo = FALSE)
    # todo send RPC election vote
    # todo if majority status = LEADER & init timer & send AppendRPC
}

onRequestVoteRPC(term, candidateId, ){
    if(term > .p2p.currentTerm && (.p2p.votedFor == NULL || .p2p.votedFor == candidateId)){
        .p2p.votedFor = candidateId;
        return(TRUE)
    }

    return(FALSE)
}

